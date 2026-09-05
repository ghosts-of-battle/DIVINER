// The layer itself
PREP(open);
PREP(close);
PREP(draw);
PREP(cycle);
PREP(toggle);
PREP(slotState);

// Whether the HUD belongs on screen at all right now, and putting it there
// or taking it away. One predicate, asked by the frame handler and the draw
// tick alike - see fnc_hidden.sqf.
PREP(hidden);
PREP(setShown);

// The scanner sweep, read once per frame for whichever tiles want it.
PREP(sweep);

// One function per readout. Each fills a slot and returns nothing; none of them
// measures anything - the data is whichever addon owns it.
PREP(widgetDrones);
PREP(widgetJamming);
PREP(widgetRadio);
PREP(widgetEw);
PREP(widgetSquad);
PREP(widgetTimer);
PREP(widgetAps);
