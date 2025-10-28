# szi

SZI tools


## Viewer

[OpenSeadragon](https://github.com/openseadragon/openseadragon) with [SZI Tile Source](https://github.com/sundogbio/szi-tile-source)

```
https://atomotic.github.io/szi/?szi-content={REMOTE_SZI}
```

[example](https://atomotic.github.io/szi/?szi-content=https://pub-0f1c9e6ddb92456a85802303778fa724.r2.dev/szi/radical-software-1-5.szi) 

Note: The CORS configuration on the remote SZI file needs to expose the `Content-Range` header.

## PDF to bookgrid 

Convert a PDF to a grid image (require VIPS and mupdf-tools)

```
./pdf-to-szi.sh
Error: Usage: ./pdf-to-szi.sh <path-to-pdf-file>
```