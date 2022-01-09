using Test

"""
Goes from a flattened density read from .cube or orca's .3D to a 
3D array. 
"""
function unflatten(flat_array; shape=(40, 40, 40))
	return permutedims(reshape(arr, (40, 40, 40)), [3, 2, 1])
end


"""
Unrols 3D array as defined for cube files
https://h5cube-spec.readthedocs.io/en/latest/cubeformat.html
http://paulbourke.net/dataformats/cube/
"""
function flatten_like_cube(density; dens_shape=(40, 40, 40))
	flattened=zeros(0)	
	for ix in 1:dens_shape[1]
		for iy in 1:dens_shape[2]
			for iz in 1:dens_shape[3]
				val = dens[ix, iy, iz]
				append!(flattened, val)
			end
		end
	end
	return flattened
end


# first four lines are metadata: 
## comment 
## x_dimension y_dimension x_dimension
## ??? (related to origin?)
## ??? (related to axes?)
#

file = readlines("dens.txt")[5:end-1]
arr = parse.(Float64, file)
dens = unflatten(arr)
flattened = flatten_like_cube(dens)
@test flattened == arr








