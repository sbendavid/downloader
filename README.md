# downloader
This script is used as a self downloader or as add-on for scripting zenity. 
It allows to download a file from the web (url) and shows its progress via zenity progress.

## usage
The downloader must receive url to process the download, it also can receive additional following parameters:

```
./downloader.sh -s [save-to-path] -o [save-as-name] URL

-s | --save-to PATH   - other PATH to where to save the downloaded file 
                        (default: saves it in the current location)
-o | --output NAME    - new NAME for the downloaded file
-h | --help           - show this help
```

## examples
 * To download **file1.mp3** from **http://some.url.com/file1.mp3** 
```
./downloader.sh http://some.url.com/file1.mp3
```

 * To download **file1.mp3** from **http://some.url.com/file1.mp3** and save it as **mysong.mp3**
```
./downloader.sh -o mysong.mp3 http://some.url.com/file1.mp3
```

 * To download **file1.mp3** from **http://some.url.com/file1.mp3** and save it in other location (**/tmp** directory)
```
./downloader.sh -s /tmp http://some.url.com/file1.mp3
```

## exit status

```
0 - the download completed successfully
1 - one of the applications (wget, zenity) is not installed
2 - failed to get the file size (broken link)
```

