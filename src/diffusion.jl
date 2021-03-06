function incell(p::Particle, b::Boundary)
    if 0.0 < p.r[2] < b.shape(p.r[1])
        return true
    else
        return false
    end
end


function singletrajectory(nsteps::Int64, nsampling::Int64, dt::Float64, Dx::Float64, Dy::Float64, b::Boundary, x0::Float64, y0::Float64)

    positions = zeros(nsteps,2) 
    temporary = zeros(nsampling,2)

    p = Particle([x0,y0], [x0,y0])
    positions[1,:] = p.r

    for i in 2:nsteps
        for k in 1:nsampling
            if k ==1
                p.rprevious =   positions[i-1,:]
                temporary[k,:] = p.rprevious
            else
                p.rprevious =   temporary[k-1,:]
            end
            p.r += sqrt(2*dt)*[sqrt(Dx)*randn(), sqrt(Dy)*randn()]
            while !incell(p,b)
                p.r = p.rprevious
                p.r += sqrt(2*dt)*[sqrt(Dx)*randn(), sqrt(Dy)*randn()]
            end                
            temporary[k,:] = p.r
        end
        positions[i,:] = p.r 
    end
    xpositions = positions[:,1]
end



function diffusion(nparticles::Int64, nsteps::Int64, nsampling::Int64, dt::Float64, Dx::Float64, Dy::Float64, lambda::Float64, shape::Function, L::Float64, x0::Float64, y0::Float64)

    b = Boundary(shape, lambda, L)

    xpositions = zeros(nsteps, nparticles)
    xpositions[:,1] = singletrajectory(nsteps, nsampling, dt, Dx, Dy, b, x0, y0)
    println("Particle 1 done")

    try
        for j in 2:nparticles
            xpositions[:,j] = singletrajectory(nsteps, nsampling, dt, Dx, Dy, b, x0, y0)
            println("Particle $j done")
        end
        return xpositions
    catch y
        if isa(y, InterruptException)
            return xpositions
        end
    end
end


function rms(positions::Array{Float64,2}, nsampling::Int64, dt::Float64)
    xsq = positions.^2
    nsteps = length(positions[:,1])
    nparticles = length(positions[1,:])

    t = 0.0:nsampling*dt:nsampling*dt*(nsteps-1)
    t = collect(t)

    xsquare = [mean(xsq[i,:]) for i in 1:nsteps]
#    xmean = [mean(positions[i,:]) for i in 1:nsteps]

    D = (xsquare)./(2*t)

    return t, D

end



