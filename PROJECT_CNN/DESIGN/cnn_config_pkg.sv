`timescale 1ns / 1ps
// =============================================================================
// cnn_config_pkg.sv  —  Centralised configuration package for the CNN pipeline
//
// Why this exists
// ----------------
// Before this package, every module (conv, conv_block, kernel_memory,
// max_pooling_block, maxpooling, flat, fully_connected_layer,
// runtime_weight_loader, cnn_top, the testbench …) re-declared its own copy
// of the same handful of numbers — PIX_WIDTH, WEIGHT_WIDTH, IMG_WIDTH, the
// per-stage CONV_IN_DIM/CONV_OUT_DIM/KERNEL_DIM arrays, etc. Any time the
// network shape changed, all of those copies had to be hunted down and
// edited in lock-step, which is exactly how silent mismatches creep in.
//
// This package is the single source of truth. Every module below now does:
//
//     module foo import cnn_config_pkg::*; #(
//         parameter int PIX_WIDTH = cnn_config_pkg::PIX_WIDTH,
//         ...
//     ) ( ... );
//
// i.e. each parameter's *default* is pulled from the package, but it is
// still a genuine module parameter — so existing #(...) instance overrides
// (e.g. a unit test instantiating `conv #(.KERNEL_DIMENSION(5)) ...`) keep
// working exactly as before. Nothing about module port lists or behaviour
// changes; this is purely deduplicating the default values.
//
// To retarget the whole design (different image size, different network
// depth, different fixed-point format, …) edit the values in this file
// once and recompile.
// -----------------------------------------------------------------------------

package cnn_config_pkg;

    // =========================================================================
    // Fixed-point datapath widths (shared by conv, conv_block, kernel_memory,
    // fully_connected_layer, runtime_weight_loader, cnn_top, …)
    // =========================================================================
    parameter int PIX_WIDTH          = 8 ;  // pixel / activation sample width
    parameter int WEIGHT_WIDTH       = 10;  // weight / bias sample width
    parameter int WEIGHT_FRACT_WIDTH = 5 ;  // fractional bits in the Qm.f weight format

    // =========================================================================
    // Top-level input image geometry
    // =========================================================================
    parameter int IMG_WIDTH  = 28;
    parameter int IMG_HEIGHT = 28;

    // =========================================================================
    // Convolution stack — one entry per conv stage
    // =========================================================================
    parameter int CONV_NUMB = 2;

    parameter int CONV_IN_DIM  [0:CONV_NUMB-1] = '{1, 4};
    parameter int CONV_OUT_DIM [0:CONV_NUMB-1] = '{4, 8};
    parameter int KERNEL_DIM   [0:CONV_NUMB-1] = '{3, 3};

    // Generic single-instance defaults used by modules that are instantiated
    // once per stage (conv, conv_block, kernel_memory, runtime_weight_loader)
    // rather than indexing the arrays above directly. Per-instance overrides
    // (as cnn_top does via CONV_IN_DIM[numb] etc.) still take priority.
    parameter int KERNEL_DIMENSION = KERNEL_DIM[0];
    parameter int IN_DIMENSION     = CONV_IN_DIM[0];
    parameter int OUT_DIMENSION    = CONV_OUT_DIM[0];

    // "TRUE"  -> conv output is truncated back down to PIX_WIDTH (re-quantised)
    // "FALSE" -> conv output keeps the full PIX_WIDTH+WEIGHT_FRACT_WIDTH growth
    parameter string TRUNK = "TRUE";

    // =========================================================================
    // Pooling stage
    // =========================================================================
    parameter int POOL_DIMENSION = 2;
    parameter int DIMENSION      = OUT_DIMENSION;  // generic channel-count default

    // =========================================================================
    // Fully-connected stack — one entry per FC layer
    // =========================================================================
    parameter int FLAT_NUMB = 2;

    parameter int FLAT_IN_DIM  [0:FLAT_NUMB-1] = '{200, 64};
    parameter int FLAT_OUT_DIM [0:FLAT_NUMB-1] = '{64 , 10};

    // =========================================================================
    // Classifier output
    // =========================================================================
    parameter int CLASSES_QNT = 10;

endpackage : cnn_config_pkg
