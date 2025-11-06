import yt_dlp
import click
from pathlib import Path

ascii_art="""
██╗   ██╗ ██████╗ ██╗   ██╗████████╗██╗   ██╗██████╗ 
╚██╗ ██╔╝██╔═══██╗██║   ██║╚══██╔══╝██║   ██║██╔══██╗
 ╚████╔╝ ██║   ██║██║   ██║   ██║   ██║   ██║██████╔╝
  ╚██╔╝  ██║   ██║██║   ██║   ██║   ██║   ██║██╔══██╗
   ██║   ╚██████╔╝╚██████╔╝   ██║   ╚██████╔╝██████╔╝
   ╚═╝    ╚═════╝  ╚═════╝    ╚═╝    ╚═════╝ ╚═════╝ 
               YouTube Video Downloader              
                    Version 1.0.0                   
"""

# Get path to save the file
def get_save_path():
    if Path.home().exists():
        save_path = Path.home() / 'Downloads'
        save_path.mkdir(parents=True, exist_ok=True)
    else:
        save_path = Path.cwd()
    return str(save_path)


@click.command()
@click.option('--url', help='Youtube Video URL')
@click.option('--type', prompt='format of the Youtube Video (mp3 or mp4)', type=click.Choice(['mp3', 'mp4']), help='Enter mp3 or mp4', default='mp4')
def main(url, type):

    save_path_str = get_save_path()

    click.echo(click.style(ascii_art, fg='cyan', bold=True))

    if type.lower() == 'mp3':
        ydl_opts = {
            'outtmpl': f'{save_path_str}/%(title)s.%(ext)s',
            'format': 'bestaudio/best',
            'postprocessors': [{
                'key': 'FFmpegExtractAudio',
                'preferredcodec': 'mp3',
                'preferredquality': '192',
            }],
            'noplaylist': True,
            'quiet': True,
            'no_warnings': True,
            'noprogress': False, # showing progress
        }
    elif type.lower() == 'mp4':
        ydl_opts = {
            'outtmpl': f'{save_path_str}/%(title)s.%(ext)s',
            'format': 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best',
            'noplaylist': True,
            'quiet': True,
            'no_warnings': True,
            'noprogress': False,
        }
    else:
        print("Invalid format. Use 'mp4' or 'mp3'")
        exit(1)

    click.echo(click.style("\nStarting to Downloading....", fg='green', bold=True))
    
    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=True)
            filename = ydl.prepare_filename(info)
            if type.lower() == 'mp3':
                filename = filename.rsplit('.', 1)[0] + '.mp3'
        click.echo(click.style("\nDownload complete!", fg='green', bold=True))
        click.echo(f'Saved to: {save_path_str}')
        click.echo(f'File: {Path(filename).name}')
    except Exception as e:
        click.echo(click.style(f'\nError: {str(e)}', fg='red', bold=True))
        exit(1)

@click.command()
@click.option('--v', help="Version")
def version():
    click.echo("Vesion 1.0.0")

if __name__ == '__main__':
    main()
