function amdgputest(model, xs...; checkgrad=true, atol=1e-6)
    cpu_model = model
    gpu_model = Flux.amd(model)

    cpu_in = xs
    gpu_in = Flux.amd.(xs)

    cpu_out = cpu_model(cpu_in...)
    gpu_out = gpu_model(gpu_in...)
    @test collect(cpu_out) ≈ collect(gpu_out) atol=atol

    if checkgrad
        cpu_grad = gradient(m -> sum(m(cpu_in...)), cpu_model)
        gpu_grad = gradient(m -> sum(m(gpu_in...)), gpu_model)
        amd_check_grad(gpu_grad, cpu_grad; atol)
    end
end

function amd_check_grad(g_gpu, g_cpu; atol)
  @show g_gpu g_cpu
  @test false
end

amd_check_grad(g_gpu::Base.RefValue, g_cpu::Base.RefValue, atol) =
    amd_check_grad(g_gpu[], g_cpu[]; atol)
amd_check_grad(g_gpu::Nothing, g_cpu::Nothing; atol) =
    @test true
amd_check_grad(g_gpu::Float32, g_cpu::Float32; atol) =
    @test g_cpu ≈ g_gpu atol=atol
amd_check_grad(g_gpu::ROCArray{Float32}, g_cpu::Array{Float32}; atol) =
    @test g_cpu ≈ collect(g_gpu) atol=atol
amd_check_grad(
    g_gpu::ROCArray{Float32}, g_cpu::Zygote.FillArrays.AbstractFill; atol,
) = @test collect(g_cpu) ≈ collect(g_gpu) atol=atol

function amd_check_grad(g_gpu::Tuple, g_cpu::Tuple; atol)
    for (v1, v2) in zip(g_gpu, g_cpu)
        amd_check_grad(v1, v2; atol)
    end
end

function amd_check_grad(g_gpu::NamedTuple, g_cpu::NamedTuple; atol)
    for ((k1, v1), (k2, v2)) in zip(pairs(g_gpu), pairs(g_cpu))
        @test k1 == k2
        amd_check_grad(v1, v2; atol)
    end
end
