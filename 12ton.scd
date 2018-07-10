// start server
s = Server.default;
s.boot;

/**
Übung 1.0 Zwölftonmatrix

Schreiben Sie eine Funktion, die die
möglichen Transformationen einer Grund-12-Ton-Reihe (baseRow) bildet.

Diese sind:
  - original: die Originalreihe,
  - retrograde: baseRow, aber rückwärts.
  - inverse: die baseRow, aber mit umgekehrten Tonschritten
             also z.B. drei Schritte hoch, wenn es in der baseRow
             drei Schritter runter geht.
  - rinv: der retrograde der inverse row.

Ausserdem soll die Reihe auf einen beliebigen gegebenen Grundton
transponiert werden, d.h. die erste Tonhöhe jeder abgeleiteten Reihe
soll diesem basePitch entsprechen.
(Achtung, das ist ein bisschen anders, als im Unterricht besprochen...).

transform: bestimmt, welche der Ableitungen gebildet werden soll.

Hints: - Bitte scrambeln Sie die Reihe nicht in der Funktion...

Gegeben die baseRow = [ 10, 4, 1, 9, 11, 5, 2, 6, 0, 7, 8, 3 ]
und den basePitch = 60 sollten die Rückgabewerte so lauten:

  - original:   [ 60, 54, 51, 59, 61, 55, 52, 56, 50, 57, 58, 53 ]
  - retrograde: [ 60, 65, 64, 57, 63, 59, 62, 68, 66, 58, 61, 67 ]
  - inverse:    [ 60, 66, 69, 61, 59, 65, 68, 64, 70, 63, 62, 67 ]
  - rinv:       [ 60, 55, 56, 63, 57, 61, 58, 52, 54, 62, 59, 53 ]

*/

~basePitch = 60;
~baseRow = [ 10, 4, 1, 9, 11, 5, 2, 6, 0, 7, 8, 3 ];

~baseRow.cu

~ttm = {arg row, baseNote, transform;
	var transformed = switch(
		transform,
		"original", {row},
		"retrograde", {row.reverse},
		"inverse", {(row - row[0]) * (-1)},
		"rinv", {~ttm.(~ttm.(row, 0, "inverse"), 0, "retrograde")},
		{transform.throw});
	var difference = baseNote - transformed[0];
	transformed + difference;
};

postln(~ttm.(~baseRow, ~basePitch, "original"));
postln(~ttm.(~baseRow, ~basePitch, "retrograde"));
postln(~ttm.(~baseRow, ~basePitch, "inverse"));
postln(~ttm.(~baseRow, ~basePitch, "rinv"));