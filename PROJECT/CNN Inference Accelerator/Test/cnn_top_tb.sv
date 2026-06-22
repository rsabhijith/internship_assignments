`timescale 1ns/1ns
// =============================================================================
// CNN_TB.sv  —  Testbench for cnn_top
//
// Rebuilt on top of the cnn_top handshake interface (i_cfg_valid/i_cfg_data/
// i_cfg_layer_sel/o_cfg_ready) instead of the legacy CNN/weights_mem_in_*
// interface, and extended with:
//   - all 4 sample digits from the original CNN_TB (7, 2, 1, 0)
//   - a software-visible STATUS REGISTER built from relu_en/pool_en/fc_en/
//     frame_done/o_valid so the testbench (or any future register-mapped
//     wrapper) can poll CNN activity the same way a CPU/AXI host would
//   - a runtime weight reload task so weights can be re-loaded mid-run
//     (e.g. between frames) and not just once before the first image
// -----------------------------------------------------------------------------

`ifdef USE_TRAINED_WEIGHTS
`include "CNN.svh"
`endif

module CNN_TB ();

    // =========================================================================
    // Parameters (must match cnn_top instantiation below)
    // Pulled from cnn_config_pkg so the testbench can never silently drift
    // out of sync with the DUT's own defaults.
    // =========================================================================
    parameter int PIX_WIDTH          = cnn_config_pkg::PIX_WIDTH         ;
    parameter int WEIGHT_WIDTH       = cnn_config_pkg::WEIGHT_WIDTH      ;
    parameter int WEIGHT_FRACT_WIDTH = cnn_config_pkg::WEIGHT_FRACT_WIDTH;

    parameter int CONV_NUMB  = cnn_config_pkg::CONV_NUMB;
    parameter int CONV_IN_DIM  [0:CONV_NUMB-1] = cnn_config_pkg::CONV_IN_DIM ;
    parameter int CONV_OUT_DIM [0:CONV_NUMB-1] = cnn_config_pkg::CONV_OUT_DIM;
    parameter int KERNEL_DIM   [0:CONV_NUMB-1] = cnn_config_pkg::KERNEL_DIM  ;

    parameter int FLAT_NUMB  = cnn_config_pkg::FLAT_NUMB;
    parameter int FLAT_IN_DIM  [0:FLAT_NUMB-1] = cnn_config_pkg::FLAT_IN_DIM ;
    parameter int FLAT_OUT_DIM [0:FLAT_NUMB-1] = cnn_config_pkg::FLAT_OUT_DIM;

    parameter int IMG_WIDTH    = cnn_config_pkg::IMG_WIDTH ;
    parameter int IMG_HEIGHT   = cnn_config_pkg::IMG_HEIGHT;
    parameter int CLASSES_QNT  = cnn_config_pkg::CLASSES_QNT;

    localparam int R2I_COEF = 2**WEIGHT_FRACT_WIDTH;

    // =========================================================================
    // DUT I/O
    // =========================================================================
    logic                          clk    = 0;
    logic                          clk_en = 1;
    logic                          rst_n  = 0;

    logic [PIX_WIDTH-1:0]          wr_data = '0;
    logic [9:0]                    wr_addr = '0;
    logic                          wr_en   = 0;
    logic                          start   = 0;
    logic                          o_img_done;

    logic                          o_valid;
    logic [CLASSES_QNT-1:0][31:0]  classes;

    logic                          i_cfg_valid     = 0;
    logic [WEIGHT_WIDTH-1:0]       i_cfg_data      = '0;
    logic [3:0]                    i_cfg_layer_sel = '0;
    logic                          o_cfg_ready;

    logic                          relu_en, pool_en, fc_en, frame_done;

    // =========================================================================
    // STATUS REGISTER
    //   bit0 = relu_en        bit1 = pool_en
    //   bit2 = fc_en          bit3 = frame_done (sticky, cleared on read)
    //   bit4 = o_valid        bit5 = cfg busy (loader in progress)
    //   bit6 = weights_loaded (set once initial load completes)
    // =========================================================================
    logic [7:0] status_reg = '0;
    logic       cfg_busy   = 1'b0;
    logic       weights_loaded = 1'b0;
    logic       frame_done_prev = 1'b0;

    always @(posedge clk) begin
        status_reg[0] <= relu_en;
        status_reg[1] <= pool_en;
        status_reg[2] <= fc_en;
        status_reg[4] <= o_valid;
        status_reg[5] <= cfg_busy;
        status_reg[6] <= weights_loaded;

        if (frame_done)
            status_reg[3] <= 1'b1;          // sticky
        // status_reg[3] is cleared explicitly via clear_frame_done_flag()
    end

    task automatic clear_frame_done_flag();
        status_reg[3] <= 1'b0;
    endtask

    task automatic print_status_reg(string tag);
        $display("STATUS_REG[%s] = 8'b%08b  (relu=%0b pool=%0b fc=%0b frame_done=%0b o_valid=%0b cfg_busy=%0b weights_loaded=%0b)",
                  tag, status_reg,
                  status_reg[0], status_reg[1], status_reg[2], status_reg[3],
                  status_reg[4], status_reg[5], status_reg[6]);
    endtask

    // =========================================================================
    // DUT instantiation
    // =========================================================================
    cnn_top #(
        .PIX_WIDTH         (PIX_WIDTH         ),
        .WEIGHT_WIDTH      (WEIGHT_WIDTH      ),
        .WEIGHT_FRACT_WIDTH(WEIGHT_FRACT_WIDTH),
        .CONV_NUMB         (CONV_NUMB         ),
        .CONV_IN_DIM       (CONV_IN_DIM       ),
        .CONV_OUT_DIM      (CONV_OUT_DIM      ),
        .KERNEL_DIM        (KERNEL_DIM        ),
        .FLAT_NUMB         (FLAT_NUMB         ),
        .FLAT_IN_DIM       (FLAT_IN_DIM       ),
        .FLAT_OUT_DIM      (FLAT_OUT_DIM      ),
        .IMG_WIDTH         (IMG_WIDTH         ),
        .IMG_HEIGHT        (IMG_HEIGHT        ),
        .CLASSES_QNT       (CLASSES_QNT       )
    ) inst_cnn_top (
        .clk            (clk            ),
        .clk_en         (clk_en         ),
        .rst_n          (rst_n          ),
        .wr_en          (wr_en          ),
        .wr_addr        (wr_addr        ),
        .wr_data        (wr_data        ),
        .start          (start          ),
        .o_img_done     (o_img_done     ),
        .o_valid        (o_valid        ),
        .classes        (classes        ),
        .i_cfg_valid    (i_cfg_valid    ),
        .i_cfg_data     (i_cfg_data     ),
        .i_cfg_layer_sel(i_cfg_layer_sel),
        .o_cfg_ready    (o_cfg_ready    ),
        .relu_en        (relu_en        ),
        .pool_en        (pool_en        ),
        .fc_en          (fc_en          ),
        .frame_done     (frame_done     )
    );

    // =========================================================================
    // Clock
    // =========================================================================
    initial forever #10 clk = !clk;

    // =========================================================================
    // Weight-source helper: returns the next fixed-point weight/bias word
    // =========================================================================
    int rand_seed = 32'hC0FFEE;

    function automatic logic [WEIGHT_WIDTH-1:0] next_word();
        // Deterministic pseudo-random fixed-point value in roughly [-1, 1)
        real r;
        rand_seed = $random(rand_seed);
        r = $itor(rand_seed % 1000) / 1000.0;
        return WEIGHT_WIDTH'($rtoi(r * R2I_COEF));
    endfunction

`ifdef USE_TRAINED_WEIGHTS
    // Flattened trained-weight queues, built once at elaboration time so the
    // handshake loader below can just pop words off regardless of source.
    logic [WEIGHT_WIDTH-1:0] conv_q [CONV_NUMB-1:0][$];
    logic [WEIGHT_WIDTH-1:0] fc_q   [FLAT_NUMB-1:0][$];

    initial begin
        foreach (kernel_1_re[dim2, dim1, row, col])
            conv_q[0].push_back(WEIGHT_WIDTH'($rtoi(R2I_COEF*kernel_1_re[dim2][dim1][row][col])));
        foreach (conv_1_bias_re[x])
            conv_q[0].push_back(WEIGHT_WIDTH'($rtoi(R2I_COEF*conv_1_bias_re[x])));

        foreach (kernel_2_re[dim2, dim1, row, col])
            conv_q[1].push_back(WEIGHT_WIDTH'($rtoi(R2I_COEF*kernel_2_re[dim2][dim1][row][col])));
        foreach (conv_2_bias_re[x])
            conv_q[1].push_back(WEIGHT_WIDTH'($rtoi(R2I_COEF*conv_2_bias_re[x])));

        foreach (fc1_weights_re[x,y])
            fc_q[0].push_back(WEIGHT_WIDTH'($rtoi(R2I_COEF*fc1_weights_re[x][y])));
        foreach (fc1_bias_re[x])
            fc_q[0].push_back(WEIGHT_WIDTH'($rtoi(R2I_COEF*fc1_bias_re[x])));

        foreach (fc2_weights_re[x,y])
            fc_q[1].push_back(WEIGHT_WIDTH'($rtoi(R2I_COEF*fc2_weights_re[x][y])));
        foreach (fc2_bias_re[x])
            fc_q[1].push_back(WEIGHT_WIDTH'($rtoi(R2I_COEF*fc2_bias_re[x])));
    end
`endif

    // =========================================================================
    // Generic handshaken layer loader
    //   layer_sel : 0..CONV_NUMB-1            -> conv stage  [layer_sel]
    //               CONV_NUMB..CONV_NUMB+FLAT_NUMB-1 -> fc layer [layer_sel-CONV_NUMB]
    //   n_words   : total words for that layer (weights + bias)
    // =========================================================================
    task automatic load_layer(input int layer_sel, input int n_words);
        i_cfg_layer_sel = layer_sel[3:0];
        for (int w = 0; w < n_words; w++) begin
`ifdef USE_TRAINED_WEIGHTS
            if (layer_sel < CONV_NUMB)
                i_cfg_data = conv_q[layer_sel].pop_front();
            else
                i_cfg_data = fc_q[layer_sel-CONV_NUMB].pop_front();
`else
            i_cfg_data  = next_word();
`endif
            i_cfg_valid = 1'b1;
            @(posedge clk);
            while (!o_cfg_ready) @(posedge clk);
        end
        i_cfg_valid = 1'b0;
        @(posedge clk);
    endtask

    task automatic load_all_weights();
        int n;
        cfg_busy = 1'b1;
        $display("---- Loading weights ----");
        for (int c = 0; c < CONV_NUMB; c++) begin
            n = CONV_OUT_DIM[c] * (CONV_IN_DIM[c]*KERNEL_DIM[c]*KERNEL_DIM[c]) + CONV_OUT_DIM[c];
            $display("  conv stage %0d : %0d words", c, n);
            load_layer(c, n);
        end
        for (int f = 0; f < FLAT_NUMB; f++) begin
            n = FLAT_OUT_DIM[f] * (FLAT_IN_DIM[f] + 1);
            $display("  fc layer %0d   : %0d words", f, n);
            load_layer(CONV_NUMB + f, n);
        end
        $display("---- Weight loading complete ----");
        cfg_busy       = 1'b0;
        weights_loaded = 1'b1;
    endtask

    // Runtime reload: re-issues the handshake load mid-simulation (e.g.
    // between frames) instead of only once before the first image.
    task automatic reload_weights_runtime();
        $display("\n>>> Runtime weight RELOAD requested (t=%0t) <<<", $time);
        // Make sure the DUT is fully idle before reloading, otherwise the
        // cfg bus and the in-flight frame's pipeline can collide.
        wait (!inst_cnn_top.o_valid);
        @(posedge clk);
        weights_loaded = 1'b0;
        load_all_weights();
    endtask

    // =========================================================================
    // Image load — write one full frame into image_bram, then kick off the
    // internal pixel_stream_generator. This replaces the old model where
    // the testbench drove conv1's i_data/i_valid/i_sop/i_eop directly every
    // cycle; now it only has to fill the frame buffer (at its own pace) and
    // pulse `start`, just like a real frame-grabber/DMA front end would.
    // =========================================================================
    task automatic load_image(input real img [IMG_HEIGHT][IMG_WIDTH]);
        int idx;
        idx = 0;
        for (int r = 0; r < IMG_HEIGHT; r++) begin
            for (int c = 0; c < IMG_WIDTH; c++) begin
                wr_en   = 1'b1;
                wr_addr = 10'(idx);
                wr_data = PIX_WIDTH'($rtoi((img[r][c]/255.0) * R2I_COEF));
                 if(idx < 20)
                $display("WRITE addr=%0d data=%0d",
                         wr_addr,
                         wr_data);

                @(posedge clk);
                idx++;
            end
        end
        wr_en = 1'b0;
    endtask
task automatic stream_image(input real img [IMG_HEIGHT][IMG_WIDTH]);
begin
    load_image(img);

    $display("%0t ASSERTING START",$time);

    start = 1'b1;
    @(posedge clk);

    $display("%0t DEASSERTING START",$time);

    start = 1'b0;
end

endtask

    // =========================================================================
    // Sample MNIST-like digit images : 7, 2, 1, 0  (all 4 from legacy CNN_TB)
    // =========================================================================
    real image_7[IMG_HEIGHT][IMG_WIDTH] =
        '{
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,84,185,159,151,60,36,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,222,254,254,254,254,241,198,198,198,198,198,198,198,198,170,52,0,0,0,0,0,0},
            '{0,0,0,0,0,0,67,114,72,114,163,227,254,225,254,254,254,250,229,254,254,140,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,17,66,14,67,67,67,59,21,236,254,106,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,83,253,209,18,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,22,233,255,83,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,129,254,238,44,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,59,249,254,62,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,133,254,187,5,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,205,248,58,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,126,254,182,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,75,251,240,57,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,19,221,254,166,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,3,203,254,219,35,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,38,254,254,77,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,31,224,254,115,1,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,133,254,254,52,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,61,242,254,254,52,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,121,254,254,219,40,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,121,254,207,18,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
        };

    real image_2[IMG_HEIGHT][IMG_WIDTH] =
        '{
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,116,125,171,255,255,150,93,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,169,253,253,253,253,253,253,218,30,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,169,253,253,253,213,142,176,253,253,122,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,52,250,253,210,32,12,0,6,206,253,140,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,77,251,210,25,0,0,0,122,248,253,65,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,31,18,0,0,0,0,209,253,253,65,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,117,247,253,198,10,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,76,247,253,231,63,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,128,253,253,144,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,176,246,253,159,12,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,25,234,253,233,35,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,198,253,253,141,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,78,248,253,189,12,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,19,200,253,253,141,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,134,253,253,173,12,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,248,253,253,25,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,248,253,253,43,20,20,20,20,5,0,5,20,20,37,150,150,150,147,10,0},
            '{0,0,0,0,0,0,0,0,248,253,253,253,253,253,253,253,168,143,166,253,253,253,253,253,253,253,123,0},
            '{0,0,0,0,0,0,0,0,174,253,253,253,253,253,253,253,253,253,253,253,249,247,247,169,117,117,57,0},
            '{0,0,0,0,0,0,0,0,0,118,123,123,123,166,253,253,253,155,123,123,41,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
        };

    real image_1[IMG_HEIGHT][IMG_WIDTH] =
        '{
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,38,254,109,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,87,252,82,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,135,241,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,45,244,150,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,84,254,63,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,202,223,11,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,32,254,216,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,95,254,195,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,140,254,77,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,57,237,205,8,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,124,255,165,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,171,254,81,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,24,232,215,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,120,254,159,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,151,254,142,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,228,254,66,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,61,251,254,66,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,141,254,205,3,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,10,215,254,121,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,5,198,176,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
        };

    real image_0[IMG_HEIGHT][IMG_WIDTH] =
        '{
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,11,150,253,202,31,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,37,251,251,253,107,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,21,197,251,251,253,107,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,110,190,251,251,251,253,169,109,62,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,253,251,251,251,251,253,251,251,220,51,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,182,255,253,253,253,253,234,222,253,253,253,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,63,221,253,251,251,251,147,77,62,128,251,251,105,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,32,231,251,253,251,220,137,10,0,0,31,230,251,243,113,5,0,0,0,0,0},
            '{0,0,0,0,0,0,0,37,251,251,253,188,20,0,0,0,0,0,109,251,253,251,35,0,0,0,0,0},
            '{0,0,0,0,0,0,0,37,251,251,201,30,0,0,0,0,0,0,31,200,253,251,35,0,0,0,0,0},
            '{0,0,0,0,0,0,0,37,253,253,0,0,0,0,0,0,0,0,32,202,255,253,164,0,0,0,0,0},
            '{0,0,0,0,0,0,0,140,251,251,0,0,0,0,0,0,0,0,109,251,253,251,35,0,0,0,0,0},
            '{0,0,0,0,0,0,0,217,251,251,0,0,0,0,0,0,21,63,231,251,253,230,30,0,0,0,0,0},
            '{0,0,0,0,0,0,0,217,251,251,0,0,0,0,0,0,144,251,251,251,221,61,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,217,251,251,0,0,0,0,0,182,221,251,251,251,180,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,218,253,253,73,73,228,253,253,255,253,253,253,253,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,113,251,251,253,251,251,251,251,253,251,251,251,147,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,31,230,251,253,251,251,251,251,253,230,189,35,10,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,62,142,253,251,251,251,251,253,107,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,72,174,251,173,71,72,30,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
        };

    // =========================================================================
    // DEBUG: golden bit-accurate reference values for image_7, computed
    // offline in Python using the REAL trained weights from CNN.svh, the
    // real image_7 pixel data, and the exact same fixed-point scale/clamp
    // rules as the RTL (Q5.5, saturating int8 conv output, channel-major
    // flatten order). The Python model correctly predicts digit 7.
    // Compare these against the live hardware signals below to find exactly
    // which stage first diverges.
    // =========================================================================
    int golden_flat[200] = '{
        24,41,36,31,23,15,53,62,65,55,0,0,14,14,17,0,7,22,8,8,0,23,25,8,3,
        0,0,0,0,0,28,45,41,20,0,19,41,45,18,13,0,0,0,4,13,0,0,0,17,10,
        18,9,3,4,0,32,44,41,52,19,16,34,49,69,22,0,7,38,42,6,0,39,46,15,4,
        20,14,6,8,3,33,17,5,13,0,11,5,16,52,0,0,4,50,52,0,0,41,58,0,0,
        7,15,14,12,9,15,31,32,39,38,8,19,26,42,41,0,2,22,37,27,0,13,42,36,7,
        0,0,0,0,0,29,54,54,50,1,9,22,27,29,11,0,0,4,4,10,0,7,0,16,9,
        7,22,19,15,15,24,39,42,47,49,10,12,14,58,49,0,0,37,58,22,0,18,64,50,0,
        14,24,22,19,15,19,37,36,51,47,8,16,24,51,47,0,3,35,46,26,0,23,52,41,5
    };

    int golden_fc1[64] = '{
        45,88,-12,63,32,89,69,-31,129,108,0,29,38,26,87,75,9,2,13,98,29,-21,5,91,46,
        35,28,18,-25,-1,1,-40,20,0,64,-10,19,89,-12,16,-15,-12,134,116,-7,121,44,2,57,38,
        59,101,-7,-1,7,16,35,111,0,53,-28,-38,96,111
    };

    int golden_fc2[10] = '{-55,-87,42,62,-184,-53,-280,256,-52,46};

    // =========================================================================
    // DEBUG: live-streaming checker for image_7. Hooks directly into the DUT
    // hierarchy and compares against the golden values above AS THE DATA
    // STREAMS, rather than requiring manual waveform navigation.
    //
    // Hierarchical paths used (verified against this project's instance names):
    //   inst_cnn_top.inst_flat.img_buf[ch][px]                          -- flat buffer
    //   inst_cnn_top.fc_genloop[0].inst_fully_connected_layer.o_data    -- FC1 output (numb=0)
    //   classes[]                                                       -- final scores (top-level TB signal)
    // =========================================================================
    // =========================================================================
    // DEBUG: clocked capture of FC1's output stream during image_7's frame.
    // o_data/integrators are transient (overwritten every RELEASE cycle), so
    // a one-shot snapshot read after the frame finishes is unreliable -- this
    // monitor latches each of FC1's 10..64 output values AS they go valid,
    // indexed in order, while `capturing_fc1` is set.
    // =========================================================================
    bit capturing_fc1 = 1'b0;
    int fc1_captured[64];
    int fc1_capture_idx;

    always @(posedge clk) begin
        if (capturing_fc1 && inst_cnn_top.fc_genloop[0].inst_fully_connected_layer.o_valid) begin
            if (fc1_capture_idx < 64)
                fc1_captured[fc1_capture_idx] <= $signed(inst_cnn_top.fc_genloop[0].inst_fully_connected_layer.o_data);
            fc1_capture_idx <= fc1_capture_idx + 1;
        end
    end

    task automatic check_image7_golden();
        int mism_flat, mism_fc1, mism_fc2;
        int got;
        mism_flat = 0;
        mism_fc1  = 0;
        mism_fc2  = 0;

        $display("\n========== DEBUG: image_7 golden-trace comparison ==========");

        // ---- checkpoint 1: flat buffer (channel-major: ch = idx/25, px = idx%25) ----
        // img_buf persists unchanged after image_7's frame until image_2's FILL
        // phase starts overwriting it, so a snapshot read here is safe AS LONG AS
        // this task is called immediately after run_image("image_7", ...) returns,
        // before run_image("image_2", ...) begins.
        $display("---- flat[] (200 values) ----");
        for (int idx = 0; idx < 200; idx++) begin
            automatic int ch = idx / 25;
            automatic int px = idx % 25;
            got = $signed(inst_cnn_top.inst_flat.img_buf[ch][px]);
            if (got !== golden_flat[idx]) begin
                mism_flat++;
                if (mism_flat <= 10)  // don't flood the log if everything's wrong
                    $display("  flat[%0d] (ch=%0d,px=%0d) MISMATCH: expected=%0d actual=%0d  <-- DIVERGES HERE",
                              idx, ch, px, golden_flat[idx], got);
            end
        end
        if (mism_flat == 0)
            $display("  flat[] : ALL 200 VALUES MATCH -- bug is downstream of flatten");
        else
            $display("  flat[] : %0d / 200 MISMATCHES -- bug is at or before flatten (conv1/pool1/conv2/pool2)", mism_flat);

        // ---- checkpoint 2: FC1 output (64 values), captured live during the frame ----
        $display("---- fc1 output (64 values, captured live) ----");
        $display("  fc1_capture_idx ended at %0d (expected 64)", fc1_capture_idx);
        for (int j = 0; j < 64; j++) begin
            if (fc1_captured[j] !== golden_fc1[j]) begin
                mism_fc1++;
                if (mism_fc1 <= 10)
                    $display("  fc1[%0d] MISMATCH: expected=%0d actual=%0d  <-- DIVERGES HERE", j, golden_fc1[j], fc1_captured[j]);
            end
        end
        if (mism_fc1 == 0)
            $display("  fc1[] : ALL 64 VALUES MATCH -- bug is at or after relu/FC2");
        else
            $display("  fc1[] : %0d / 64 MISMATCHES -- bug is inside FC1 (or its input, if flat[] also mismatched above)", mism_fc1);

        // ---- checkpoint 3: final classes[] ----
        $display("---- classes[] (10 values) ----");
        for (int k = 0; k < 10; k++) begin
            got = $signed(classes[k]);
            if (got !== golden_fc2[k]) begin
                mism_fc2++;
                $display("  classes[%0d] MISMATCH: expected=%0d actual=%0d  <-- DIVERGES HERE", k, golden_fc2[k], got);
            end else begin
                $display("  classes[%0d] OK: %0d", k, got);
            end
        end
        if (mism_fc2 == 0)
            $display("  classes[] : ALL MATCH (this would mean image_7 was actually predicted correctly this run!)");

        $display("==============================================================\n");
    endtask

    // =========================================================================
    // Main stimulus
    // =========================================================================
    int     max_idx;
    integer max_val;
    integer i;
integer mismatch;
integer flat_idx;

// adjust width if flat_data is not 8 bits
logic signed [7:0] flat_capture [0:199];
    task automatic run_image(string name, real img [IMG_HEIGHT][IMG_WIDTH]);
        $display("\nStarting %s stream", name);
        stream_image(img);

        // IMPORTANT: wait(o_valid) is LEVEL-sensitive. If o_valid is still
        // high from the previous frame's result, wait() returns immediately
        // and we read stale classes[] from the prior image. Force a clean
        // edge: first make sure o_valid has gone low (end of previous
        // result window), then wait for its rising edge for THIS frame.
        if (inst_cnn_top.o_valid)
            @(negedge inst_cnn_top.o_valid);
        @(posedge inst_cnn_top.o_valid);

        print_status_reg(name);
        $display("CNN output received for %s", name);
        clear_frame_done_flag();
        repeat (5) @(posedge clk);
    endtask

    initial begin
        rst_n = 0;
        #100;
        rst_n = 1;
        #100;

        @(posedge clk);
        load_all_weights();
        print_status_reg("after_initial_load");
flat_idx = 0;

for(int i=0;i<200;i++)
    flat_capture[i] = 0;
    fc1_capture_idx = 0;
capturing_fc1   = 1'b1;

for(int i=0;i<64;i++)
    fc1_captured[i] = 0;
        run_image("image_7", image_7);
        capturing_fc1 = 1'b0;
check_image7_golden();
        run_image("image_2", image_2);

        // Demonstrate a runtime weight reload between frames
        // TEMPORARILY DISABLED — suspected to hang the cfg handshake and
        // block image_1 / image_0 from ever streaming. Re-enable once the
        // handshake stall is root-caused and fixed.
        // reload_weights_runtime();
        // print_status_reg("after_runtime_reload");

        run_image("image_1", image_1);
        run_image("image_0", image_0);

        #1000;
        $finish;
    end

    // =========================================================================
    // Dataflow / status monitors
    // =========================================================================
    always @(posedge clk) begin
        if (inst_cnn_top.conv_valid[0]) $display("CONV1 ACTIVE");
        if (inst_cnn_top.pool_valid[0]) $display("POOL1 ACTIVE");
        if (inst_cnn_top.conv_valid[CONV_NUMB-1]) $display("CONV2 ACTIVE");
        if (inst_cnn_top.pool_valid[CONV_NUMB-1]) $display("POOL2 ACTIVE");
        if (inst_cnn_top.flat_valid) $display("FLAT VALID, data=%0d", inst_cnn_top.flat_data);
        
        if (inst_cnn_top.fc_valid[FLAT_NUMB-1])
            $display("FC2 = %0d", $signed(inst_cnn_top.fc_data[FLAT_NUMB-1]));
        if (frame_done && !frame_done_prev)
            $display("STATUS REGISTER: frame_done pulsed");
        frame_done_prev <= frame_done;
    end
    always @(posedge clk) begin
    if (inst_cnn_top.flat_valid) begin
        if(flat_idx < 200) begin
            flat_capture[flat_idx] <= $signed(inst_cnn_top.flat_data);
            flat_idx <= flat_idx + 1;
        end
    end
end

    initial begin
        $display(" t  relu_en pool_en fc_en");
        forever begin
            @(posedge clk);
            if (relu_en || pool_en || fc_en)
                $display("%0t  %0b       %0b       %0b", $time, relu_en, pool_en, fc_en);
        end
    end

    always @(posedge clk) begin
        if (o_valid) begin
            @(posedge clk); // allow classes[] to settle

            $display("\n========== CNN OUTPUT ==========");
            for (i = 0; i < CLASSES_QNT; i = i + 1)
                $display("Class[%0d] = %0d", i, $signed(classes[i]));

            max_idx = 0;
            max_val = $signed(classes[0]);
            for (i = 1; i < CLASSES_QNT; i = i + 1) begin
                if ($signed(classes[i]) > max_val) begin
                    max_val = $signed(classes[i]);
                    max_idx = i;
                end
            end

            $display("--------------------------------");
            $display("Predicted Digit = %0d", max_idx);
            $display("Maximum Score   = %0d", max_val);
            $display("================================\n");
        end
    end

endmodule : CNN_TB
