module Flux

using Base: tail
using Preferences
using LinearAlgebra, Statistics, Random  # standard lib
using MacroTools, Reexport, ProgressLogging, SpecialFunctions
using MacroTools: @forward

@reexport using NNlib
using MLUtils
import Optimisers: Optimisers, trainable, destructure  # before v0.13, Flux owned these functions
using Optimisers: freeze!, thaw!, adjust!

using Zygote, ChainRulesCore
using Zygote: Params, @adjoint, gradient, pullback
using Zygote.ForwardDiff: value
export gradient

# Pirate error to catch a common mistake. (Internal function `base` because overloading `update!` is more likely to give ambiguities.)
Optimisers.base(dx::Zygote.Grads) = error("Optimisers.jl cannot be used with Zygote.jl's implicit gradients, `Params` & `Grads`")

export Chain, Dense, Embedding, Maxout, SkipConnection, Parallel, PairwiseFusion,
       RNN, LSTM, GRU, GRUv3,
       SamePad, Conv, CrossCor, ConvTranspose, DepthwiseConv,
       AdaptiveMaxPool, AdaptiveMeanPool, GlobalMaxPool, GlobalMeanPool, MaxPool, MeanPool,
       Dropout, AlphaDropout, LayerNorm, BatchNorm, InstanceNorm, GroupNorm,
       Upsample, PixelShuffle,
       fmap, cpu, gpu, f32, f64, f16, rand32, randn32, zeros32, ones32,
       testmode!, trainmode!

include("optimise/Optimise.jl")
using .Optimise
using .Optimise: @epochs
using .Optimise: skip
export Descent, Adam, Momentum, Nesterov, RMSProp,
  AdaGrad, AdaMax, AdaDelta, AMSGrad, NAdam, OAdam,
  AdamW, RAdam, AdaBelief, InvDecay, ExpDecay,
  WeightDecay, ClipValue, ClipNorm

export ClipGrad, OptimiserChain  # these are const defined in deprecations, for ClipValue, Optimiser

include("train.jl")
using .Train
using .Train: setup

using CUDA
const use_cuda = Ref{Union{Nothing,Bool}}(nothing)

using Adapt, Functors, OneHotArrays
include("utils.jl")
include("functor.jl")

# Pirate error to catch a common mistake.
Functors.functor(::Type{<:MLUtils.DataLoader}, x) = error("`DataLoader` does not support Functors.jl, thus functions like `Flux.gpu` will not act on its contents.")

include("layers/stateless.jl")
include("layers/basic.jl")
include("layers/conv.jl")
include("layers/recurrent.jl")
include("layers/normalise.jl")
include("layers/upsample.jl")
include("layers/show.jl")

include("loading.jl")

include("outputsize.jl")
export @autosize

include("losses/Losses.jl")

include("deprecations.jl")

include("cuda/cuda.jl")

end # module
