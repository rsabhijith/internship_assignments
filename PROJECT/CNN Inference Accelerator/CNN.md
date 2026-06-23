# CNN Inference Accelerator Using SystemVerilog


#  Abstract

This project implements a Convolutional Neural Network (CNN) hardware accelerator using SystemVerilog. The design processes image data through a sequence of neural network operations including convolution, activation, pooling, flattening, and fully connected layers. The accelerator is organized as a modular architecture consisting of dedicated processing blocks, memory components, control logic, and runtime weight-loading support.

The system accepts image data from memory, performs feature extraction using convolution operations, applies ReLU activation, reduces feature-map dimensions through max pooling, converts multidimensional data into a one-dimensional representation using a flatten layer, and finally performs classification through fully connected layers. The design also supports loading trained parameters through a runtime weight-loading mechanism.

---

#  Project Objective

The objective of this project is to implement a hardware-based CNN accelerator capable of executing neural network inference operations using SystemVerilog. The design aims to provide a modular and structured implementation of CNN processing stages while supporting configurable parameters and runtime weight loading.

---

#  Project Architecture

The accelerator is composed of the following major modules:

* CNN Configuration Package
* Image BRAM
* Pixel Stream Generator
* Convolution Engine
* Convolution Processing Block
* Kernel Memory
* Runtime Weight Loader
* ReLU Activation Layer
* Max Pooling Engine
* Max Pooling Block
* Flatten Layer
* Fully Connected Layer
* Status Register Controller
* Top-Level CNN Integration
* Verification Testbench

The processing flow is:

Image Memory → Pixel Stream Generator → Convolution → ReLU → Max Pooling → ReLU → Max Pooling → Flatten → Fully Connected Layer(s)

---

#  Design Files

| File Name                 | Description                                     |
| ------------------------- | ----------------------------------------------- |
| cnn_top.sv                | Top-level CNN integration module                |
| cnn_config_pkg.sv         | Configuration package containing CNN parameters |
| conv.sv                   | Convolution processing engine                   |
| conv_block.sv             | Convolution block implementation                |
| relu.sv                   | ReLU activation layer                           |
| maxpooling.sv             | Max pooling engine                              |
| max_pooling_block.sv      | Pooling block wrapper                           |
| flat.sv                   | Flatten layer                                   |
| fully_connected_layer.sv  | Fully connected neural network layer            |
| kernel_memory.sv          | Storage for kernels and biases                  |
| runtime_weight_loader.sv  | Runtime parameter loading interface             |
| image_bram.sv             | Image storage memory                            |
| pixel_stream_generator.sv | Pixel streaming module                          |
| status_register.sv        | CNN stage controller                            |
| cnn_top_tb.sv             | Verification testbench                          |
| CNN.svh                   | Trained weights and biases                      |

---

#  CNN Configuration Package

## Module: cnn_config_pkg

The configuration package contains global parameters used throughout the design.

### Purpose

* Centralized parameter definition
* Consistent configuration across modules
* Simplified maintenance and scalability

### Contents

The package defines CNN-related parameters including:

* Pixel widths
* Weight widths
* Fraction widths
* Image dimensions
* Convolution dimensions
* Kernel dimensions
* Flatten layer dimensions
* Number of output classes

All CNN modules obtain configuration values from this package.

---

#  Image Memory

## Module: image_bram

### Purpose

The image BRAM module stores image data that serves as input to the CNN accelerator.

### Functionality

* Stores image pixels in memory
* Provides image data through memory access interfaces
* Supplies image information to the pixel streaming module

This module acts as the input image buffer for the CNN pipeline.

---

#  Pixel Stream Generator

## Module: pixel_stream_generator

### Purpose

The pixel stream generator converts stored image data into a sequential pixel stream suitable for processing by downstream CNN modules.

### Functionality

* Reads pixels from image memory
* Generates continuous pixel output
* Produces control signals for stream synchronization
* Indicates beginning and end of image data transmission

### Outputs

The module generates:

* Pixel data
* Valid signal
* Start-of-packet indication
* End-of-packet indication
* Completion indication

---

#  Convolution Engine

## Module: conv

### Purpose

The convolution module performs convolution operations on incoming image data.

### Functionality

* Receives pixel data
* Applies convolution kernels
* Performs multiply-accumulate operations
* Produces filtered outputs

The module forms the computational core of feature extraction within the CNN architecture.

### Architecture of a MAC Engine
<img width="647" height="221" alt="Screenshot 2026-06-23 092607" src="https://github.com/user-attachments/assets/24e2efd8-3360-4241-b2bc-156a3ce1b2b9" />






---

#  Convolution Processing Block

## Module: conv_block

### Purpose

The convolution block organizes and manages convolution processing operations.

### Functionality

* Interfaces with convolution logic
* Accesses kernel memory
* Processes convolution results
* Supports CNN feature extraction stages

The module acts as a higher-level processing block around convolution operations.

---

#  Kernel Memory

## Module: kernel_memory

### Purpose

Kernel memory stores trained CNN parameters.

### Stored Data

* Convolution kernels
* Bias values
* Network parameters

### Functionality

* Supplies parameters to convolution layers
* Provides trained values required during inference
* Interfaces with runtime loading logic

---

#  Runtime Weight Loader

## Module: runtime_weight_loader

### Purpose

The runtime weight loader allows CNN parameters to be loaded into memory after system initialization.

### Functionality

* Receives configuration data
* Generates memory addresses
* Controls parameter loading
* Transfers weights into storage structures

### Advantages

* Flexible parameter updates
* No RTL modification required for new parameter sets
* Supports runtime configuration

---

#  ReLU Activation Layer

## Module: relu

### Purpose

The ReLU module implements the Rectified Linear Unit activation function.

### Activation Function

ReLU(x) = max(0, x)

### Functionality

* Checks the sign of each input value
* Negative values are converted to zero
* Positive values remain unchanged

### Role in CNN

The ReLU layer introduces non-linearity into the neural network and is positioned after convolution operations.

---

#  Max Pooling Engine

## Module: maxpooling

### Purpose

The max pooling engine performs pooling operations on feature maps.

### Functionality

* Forms pooling windows
* Compares values within the window
* Selects the maximum value
* Produces reduced feature-map outputs

### Benefits

* Feature-map reduction
* Reduced computational complexity
* Preservation of dominant features

---

# Max Pooling Block

## Module: max_pooling_block

### Purpose

This module provides block-level pooling functionality.

### Functionality

* Receives feature-map data
* Performs pooling operations
* Produces pooled outputs
* Generates completion indication

The block serves as a wrapper around the pooling process.

---

#  Flatten Layer

## Module: flat

### Purpose

The flatten layer converts multidimensional feature-map data into a one-dimensional representation.

### Functionality

* Collects pooled feature-map outputs
* Rearranges data into vector format
* Prepares data for fully connected processing

### Position in Pipeline

The flatten layer is located between the pooling stage and the fully connected stage.

### Flat Layer State Machine

<img width="897" height="677" alt="image" src="https://github.com/user-attachments/assets/16571cea-3830-4669-811e-5c7930c9e401" />


---

#  Fully Connected Layer

## Module: fully_connected_layer

### Purpose

The fully connected layer performs dense neural network computation.

### Functionality

* Receives flattened input vectors
* Applies trained weights
* Adds bias values
* Produces neuron outputs

### Role

This module performs the final stages of inference processing and generates network outputs.

### Fully Connected Layer State Machine

<img width="891" height="697" alt="image" src="https://github.com/user-attachments/assets/e730dd71-8686-498e-a1ce-926a64960786" />


---

#  Status Register Controller

## Module: status_register

### Purpose

The status register manages CNN execution flow.

### States

* IDLE
* RELU1
* POOL1
* RELU2
* POOL2
* FC1
* FC2
* DONE

### Functionality

* Controls stage progression
* Tracks CNN execution status
* Indicates processing completion
* Coordinates module activation

### Status Register State Machine

<img width="1310" height="415" alt="image" src="https://github.com/user-attachments/assets/5e3b4184-dd9f-46ba-a617-5d0d90a072f7" />






---

#  Top-Level Integration

## Module: cnn_top

### Purpose

The top-level module integrates all CNN processing components.

### Integrated Modules

* Image BRAM
* Pixel Stream Generator
* Convolution Block
* ReLU Layer
* Max Pooling Block
* Flatten Layer
* Fully Connected Layer
* Runtime Weight Loader
* Status Register

### Responsibilities

* System integration
* Data routing
* Signal coordination
* CNN pipeline control

The module represents the complete CNN hardware accelerator.

---

#  Verification Environment

## Module: cnn_top_tb

### Purpose

The testbench verifies the operation of the complete CNN accelerator.

### Verification Scope

* Image streaming
* Convolution processing
* ReLU activation
* Max pooling
* Flatten operation
* Fully connected layer operation
* Runtime weight loading
* Top-level integration

### Supporting File

The file `CNN.svh` contains trained parameters used during simulation and verification.

---

#  Data Flow

The overall processing sequence is:

1. Image data is stored in image memory.
2. Pixel stream generator produces sequential pixel data.
3. Convolution operations extract image features.
4. ReLU activation processes convolution outputs.
5. Max pooling reduces feature-map dimensions.
6. Additional CNN stages continue processing.
7. Flatten converts feature maps into vector format.
8. Fully connected layers perform dense computation.
9. Final outputs are generated.

---

#  Conclusion

 Implemented a CNN Inference Accelerator in SystemVerilog on Artix-7 FPGA using two convolution layers, ReLU, max-pooling, flattening, and two fully connected layers. The design successfully classified MNIST test images (0,1,2,7) with 100% accuracy in simulation.


 ### Tcl Console Output

 <img width="507" height="410" alt="image" src="https://github.com/user-attachments/assets/8c798019-c322-4aab-8a7e-6b4215efe084" />
 <img width="417" height="391" alt="image" src="https://github.com/user-attachments/assets/ae73b9dc-2d66-433b-b362-0dfd2261c28d" />

 ### Simulation Waveform

 <img width="1600" height="1027" alt="image" src="https://github.com/user-attachments/assets/da08f5be-1497-4755-a298-31ee288976b8" />
 <img width="1600" height="1017" alt="image" src="https://github.com/user-attachments/assets/e74b0993-6adc-4e82-ba4c-1ba879b6425a" />





 
 
