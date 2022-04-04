//
//  PureBlackWhiteShader.metal
//  SudokuHelper
//
//  Created by Peter Schuette on 3/26/22.
//

#include <metal_stdlib>
using namespace metal;

#include <CoreImage/CoreImage.h>

extern "C" {
  namespace coreimage {
    float4 thresholdFilterKernel(sampler src, float threshold) {
      float4 input = src.sample(src.coord());
      float luma = dot(input.rgb, float3(0.2126, 0.7152, 0.0722));
      float value = step(threshold, luma);
      float3 rgb = float3(value);
      return float4(rgb, input.a);
    }
  }
}
