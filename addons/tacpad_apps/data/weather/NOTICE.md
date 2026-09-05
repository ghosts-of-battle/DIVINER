# Weather icons

Derived from an Adobe Stock vector icon set (asset **2116238417**), licensed by
the mod author. Retain the licence record with the project.

They are not the supplied artwork as-is. The source is a flat two-colour sheet
on a solid white background with no alpha - a JPEG cannot carry any - so each
icon was cut out, the white keyed to transparency by distance-from-white, and
the remaining pixels flattened to white. What ships is a **silhouette in the
alpha channel only**.

That is deliberate. The suite is near-monochrome and repaints from three runtime
tokens; a baked blue-and-yellow icon would be the one thing on the map screen
that ignored the player's colour scheme. As alpha, `ghost_tacpad_fnc_drawIcon`
tints each one to ink or accent at draw time and they follow the theme like
everything else.

The white strokes the artwork uses to separate an overlapping sun from a cloud
become gaps in the silhouette, which is what they read as once tinted.

Ten of the twenty-five on the sheet are kept - the ones the weather tile can
actually reach from `overcast`, `rain`, `fog`, `wind` and time of day.
