# Grounded Tree Selection Box

## Overview

This is a *Factorio* mod that adjusts the mouse cursor selection boxes of trees to be less obtrusive, making it easier to interact with entities behind trees without removing the trees first.

## Features

- Works on both base *Factorio* trees and *Space Age* growable plants
- Applies to all `tree` and `plant` entities that have both a non-empty collision box and selection box defined
- Configurable settings to control the size basis, position, shape, padding, and size limits of selection boxes

## Caveats

The selection boxes of growable plants from *Space Age* appear to scale based on the growth stage of the plants. Thus, a young plant can have a selection box smaller than the mod's configured minimum size. For this reason, size limits can be specified separately for growable plants. When fully grown, their selection box may be quite large as a result, but since they are usually spaced further apart, this generally acceptable.
