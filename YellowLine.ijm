// Characteristics: This does the whole workflow, and avoids creating an entire mess-of-a-folder.
// It takes less memory, and the final finished product is nice and concise. Must save then, though.

// Tasks:

/*
 * 1) Dialog prompt
 * 2) Basic operation using COMBINE
 * 3) For loop
 * 4) 
 */

//Tidywork:

// Close all windows, establish standard settings
// also, could ensure the new title is relevant to the first
// will NOT auto-save, bc it produces a tangible and it is important the interacting scientist knows
// where it is saved, as it will most likely be used on an ad-hoc basis.
// - could ensure the video is of proper "A" format...

// 1) Dialog prompt(s)

// Which video (z-stack-by-time)?
filepath=File.openDialog("Select a Movie");
open(filepath);

// Which kymo?
Dialog.create("Choose the visualization-type")

// Features:

// which X?
Dialog.addChoice("X Kymograph type:", newArray("None", "Average", "Max", "Min", "Sum", "SD", "Median"), "None");
Dialog.addCheckbox("Type-label?", true);
// which Y?
Dialog.addChoice("Y Kymograph type:", newArray("None", "Average", "Max", "Min", "Sum", "SD", "Median"), "None");
Dialog.addCheckbox("Type-label?", true);

Dialog.setLocation(400,250);
// add help box...
  html = "<html>"
     +"<h2>What are these options?</h2>"
     +"<font size=-1>
     +"<b>X-Kymo:</b> <font color=red>Preserves the X-dimension</font>, while switching the orientation of the Time-dimension & Y-dimension,<br>"
     + "then collapsing the Y-dimension's associated pixel intensities with the chosen operation.<br>"
     + "e.g. 'Max' yielding the highest 8-bit value <i>out-of-all</i> the Y-values<br>"
     + "<font color=red>tl;dr</font> - The 'classic' Kymograph– looks like a broken wish-bone."
     +"<br><br/>"
     +"<b>Type-Label?:</b> Burns in (or 'flattens' in ijm-jargon) a label of which operation was performed on the Kymograph.<br>"
     +"Changes the pixel-data; avoid if further calculations are desired.<br>"
     +"<br>"
     +"<b>Y-Kymo:</b> <font color=red>Preserves the Y-dimension</font>, while switching the orientation of the Time-dimension & Y-dimension,<br>"
     + "then collapsing the Y-dimension's associated pixel intensities with the chosen operation.<br>"
     + "e.g. 'Max' yielding the highest 8-bit value <i>out-of-all</i> the Y-values<br>"
     + "<font color=red>tl;dr</font> - The 'classic' Kymograph– looks like a broken wish-bone."
     +"<br><br/>"
     +"<b>Choosing both:</b> A scrollable image will be formatted as would be expected."
     +"<br><br/>"
     +"</font>";
  Dialog.addHelp(html);
// Trigger the interaction
Dialog.show();

// Harvest the information
// The X-Kymograph... 
x_type_arg = "projection=[" + Dialog.getChoice(); "]");
x_label_flag = Dialog.getCheckbox();
//print("The x_type is..." + x_type);
//print(x_label_flag);
// The Y-Kymograph...
y_type = Dialog.getChoice();
y_label_flag = Dialog.getCheckbox();
//print("The y_type is..." + y_type);
//print(y_label_flag);

// So far... original video is OPEN... the kymographs are NOT made

// Make X Kymograph (will run macros to accomplish this)
if(x_type== "None") {
	// Do nothing
}
else {
	run("Reslice [/]...", "output=1.000 start=Left rotate");
	// now i have a new stack
	// open: original + kymo-stack
	run("Z Project...", x_type_arg);
	// open: original + kymo-slice + kymograph
	close("Reslice*");
	
}
// Close-out old re-sliced STACK (un-compressed kymograph)

// Make Y Kymograph

if(y_type== "None") {
	// Do nothing
}
else {
	run("Reslice [/]...", "output=1.000 start=Left rotate");
	// now i have a new stack
	// open: original + kymo-stack
	run("Z Project...", y_type_arg);
	// open: original + kymo-slice + kymograph
	close("Reslice*");
}


// Close-out old re-sliced STACK (un-compressed kymograph)




