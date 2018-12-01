Sleuth Example
====

Reads in an 'encrypted' file called data.node and runs it through the 'sleuth' algorithm to produce an MP4.

Build & Run Instructions
------
`dub build --build=release`

`./bindgen`

`./main.rb`

Benchmark
------
After executing the above commands you can also run `./benchmark` to see the Ruby performance vs the compiled D library.