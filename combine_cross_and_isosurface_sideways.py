import os
import re
import subprocess
import click
from tqdm import tqdm

@click.command()
@click.option('--cross_section_dir', show_default=True,
              default='/Users/elena/code/carbyne_comulene'
                      '/vmd_cross_sections')
@click.option('--isosurface_dir', show_default=True, 
              default='/Users/elena/code/carbyne_comulene/vmd_isosurfaces')
@click.option('--output_dir', show_default=True,
              default='/Users/elena/code/carbyne_comulene'
                      '/combined_density_and_cross_section')
def main(cross_section_dir, isosurface_dir, output_dir):

    if not os.path.isdir(output_dir):
        os.makedirs(output_dir)

    fnames_cross = [os.path.join(cross_section_dir, fname) for fname in
               os.listdir(cross_section_dir)]

    fnames_iso = [os.path.join(isosurface_dir, fname) for fname in
               os.listdir(isosurface_dir)]


    for fname_cross, fname_iso in tqdm(zip(fnames_cross, fnames_iso)):

        fname_joined = os.path.join(output_dir, os.path.splitext(
            os.path.basename(fname_cross))[0])

        command =  f'convert +append {fname_iso} {fname_cross} ' \
                   f'{fname_joined}.tga'
        subprocess.run(command, shell=True)



if __name__=='__main__':
    main()
