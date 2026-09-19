<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

Placeholder while the protocol engine is designed: `uo_out` is the 8-bit sum of `ui_in` and `uio_in`, written in Hardcaml
(`hw/rtl/top.ml`).

## How to test

Drive `a` on `ui_in` and `b` on `uio_in`. `uo_out` shows `a + b` modulo 256.

## External hardware

None.
