import os
import subprocess
import click
from tqdm import tqdm

@click.command()
@click.option('--vmd_dir', show_default=True,
              default='/Users/elena/code/carbyne_comulene/vmd_plots')
@click.option('--pdf_dir', show_default=True,
              default='/Users/elena/code/carbyne_comulene/pdf_plots')
def main(vmd_dir, pdf_dir):

    if not os.path.isdir(pdf_dir):
        os.makedirs(pdf_dir)

    filenames = [os.path.join(vmd_dir, fname) for fname in os.listdir(
        vmd_dir)]

    for filename in tqdm(filenames):

        base = os.path.basename(os.path.splitext(filename)[0])
        target_fname = os.path.join(pdf_dir, base + '.pdf')

        exec = f"convert {filename} -gravity North -draw 'scale 4,4 text 0," \
               f"10 {base}' {target_fname}"

        subprocess.run(exec, shell=True)



if __name__=='__main__':
    main()
