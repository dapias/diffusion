include("../src/straightchannel.jl")

function diffusionstraight(nparticles::Int64, nsteps::Int64, nsampling::Int64, dt::Float64, Dx::Float64, Dy::Float64)

    positions = zeros(nsteps,2, nparticles)
    temporary = zeros(nsampling,2)

    for j in 1:nparticles
        p = Particle([0.,0.], [0.,0.])
        positions[1,:,j] = p.r

        for i in 2:nsteps
            for k in 1:nsampling
                if k ==1
                    p.rprevious =   positions[i-1,:,j]
                    temporary[k,:] = p.rprevious
                else
                    p.rprevious =   temporary[k-1,:]
                end
                p.r += sqrt(2*dt)*[Dx*randn(), Dy*randn()]
                straightboundaries(p)
                temporary[k,:] = p.r
            end
            positions[i,:,j] = p.r 
        end
        println("Particle $j done")
    end
end


