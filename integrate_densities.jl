using Pkg
Pkg.activate("./integrate_densities")

using Plots
using ASE
using JuLIP


cubes_dir = "all_200x200x200_densities"
output_dir = "plots_integrated_densities"

function unflatten(flat_array; shape=(40, 40, 40))
    return permutedims(reshape(flat_array, shape), [3, 2, 1])
end


"""
Returns points along given coordinate to which the density points correspond 
"""
function convert_axis(origin, axes; which_axis=1, dimensions=(40, 40, 40))
    range = Array(1:dimensions[which_axis])
    # cannot do shearing 
    scaled = range * axes[which_axis][which_axis]
    shifted = [x + origin[which_axis] - axes[which_axis][which_axis] for x in scaled]
    return shifted
end


"""
reads information from .cube file
"""
function read_file(filename)

    file = readlines(filename)

    # two lines of comments
    # third line: number of atoms (int) and origin (3 x float)
    n_atoms = parse(Int64, split(file[3])[1])
    origin = parse.(Float64, split(file[3])[2:4])

    # fourth-sixth lines - number of voxels along each axis and the axis. 
    # Take only number of voxels (for now?)    
    dens_shape = Tuple([parse(Int64, split(file[i])[1]) for i in 4:6])
    axes = [parse.(Float64, split(file[i])[2:4]) for i in 4:6]

    # `n_atoms` of geometry data
    numbers = [parse(Int64, split(file[i])[1]) for i in 7:6+n_atoms]
    pos = [parse.(Float64, split(file[i])[3:5]) for i in 7:6+n_atoms]
    atoms = Atoms(X=pos, Z=numbers)

    # density data starts after `n_atoms` lines of geometry data
    flat_values=zeros(0)
    for line in file[7+n_atoms:end]
        numbers = parse.(Float64, split(line))
        append!(flat_values, numbers)
    end

    density = unflatten(flat_values, shape=dens_shape);

    return origin, axes, atoms, density, dens_shape

end

"""
sums over slices of arrays
"""
function integrate(data; step=40)
    output=zeros(0)
    for idx in 1:step
        slice = data[idx,:,:]
        append!(output, sum(slice))
    end
    return output
end

function plot_plot(filename, output_filename)

    title = split(filename, "/")[end]
    origin, axes, atoms, el_density, dens_shape = read_file(filename)
    integral = integrate(el_density, step=dens_shape[1])

    x_vals = convert_axis(origin, axes, dimensions=dens_shape)
    at_pos = [atoms.X[i][1] for i in 1:length(atoms.Z) if atoms.Z[i] == 6]
    plot(x_vals, integral, label="xy-integrated density", lw=2)
    vline!(at_pos, label="Carbon atoms' positions", lw=0.5)
    xlabel!("z coordinate")
    savefig(output_filename)
end



if !isdir(output_dir)
    mkdir(output_dir)
end


### go through files and make the plots 
filenames = [fname for fname in readdir(cubes_dir) if occursin("cube", fname)]
for filename in filenames
    filename = "HC33H.triplet_opt.uks_def2-svp_opt.dlpno-ccsd_cc-pvdz.triplet.mdci.spindens.cube" 
    output_filename = replace(filename, ".cube" => ".pdf")
    output_filename = "$(output_dir)/$(output_filename)"
    plot_plot("$(cubes_dir)/$(filename)", output_filename)
    break
end

