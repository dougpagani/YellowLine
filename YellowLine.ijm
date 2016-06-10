TILL = 25;

// Characteristics: This does the whole workflow, and avoids creating an entire mess-of-a-folder.
// It takes less memory, and the final finished product is nice and concise. Must save then, though.

// Selection functions:
// 1- selectImage(id)
// 2- selectWindow("name")

// Tasks:

/*
 * 1) Dialog prompt
 * 2) Basic operation using COMBINE
 * 3) For loop
 * 4) 
 */

// TODO:
// 1) pixel-scale reset (maybe can preserve thing by using toUnscaled(length)
// 2) make a 2-bit line...

/* Tidywork:

// Close all windows, establish standard settings
// also, could ensure the new title is relevant to the first
// will NOT auto-save, bc it produces a tangible and it is important the interacting scientist knows
// where it is saved, as it will most likely be used on an ad-hoc basis.
 - could ensure the video is of proper "A" format...
 - set titles if desired
*/

//Clearing Fiji of all open images and windows
showMessageWithCancel("WARNING", "First, all files open in FIJI will be closed. \n \nSave desired image-files.");
// If no cancel...
while (nImages>0) {selectImage(nImages); close();}
if (isOpen("Results")) {selectWindow("Results"); run("Close");}
if(isOpen("ROI Manager")){selectWindow("ROI Manager");run("Close");}
if(isOpen("Log")){selectWindow("Log");run("Close");}
if(isOpen("Debug")){selectWindow("Debug");run("Close");}


///// 1) Dialog prompt(s)

// Which video (z-stack-by-time)?
filepath=File.openDialog("Select a Movie");
open(filepath);
fp_name=getTitle();
mainID=getImageID();
// Change the scale to pixels so integers can promote a clean re-slice into the kymos
run("Properties...", 
"channels=1 slices=561 frames=1 unit=µm pixel_width=1 pixel_height=1 voxel_depth=1.0000000 frame=[1 sec]");

// Which kymo?
Dialog.create("Choose the visualization-type")

// Features:

// which X?  --- menu items must match the argument-flags of Z-Project
Dialog.addChoice("X Kymograph type:", newArray("None", "Average Intensity", "Max Intensity", "Min Intensity", "Sum Slices", "Standard Deviation", "Median"), "None");
//Dialog.addChoice("X Kymograph type:", newArray("None", "Average", "Max", "Min", "Sum", "SD", "Median"), "None");
Dialog.addCheckbox("Type-label?", true);
// which Y?
Dialog.addChoice("Y Kymograph type:", newArray("None", "Average Intensity", "Max Intensity", "Min Intensity", "Sum Slices", "Standard Deviation", "Median"), "None");
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
x_type = Dialog.getChoice();
x_type_arg = "projection=[" + x_type + "]";
x_label_flag = Dialog.getCheckbox();
//print("The x_type is..." + x_type);
//print(x_label_flag);
// The Y-Kymograph...
y_type = Dialog.getChoice();
y_type_arg = "projection=[" + y_type + "]";
y_label_flag = Dialog.getCheckbox();
//print("The y_type is..." + y_type);
//print(y_label_flag);

// So far... original video is OPEN... the kymographs are NOT made

// Make X Kymograph (will run macros to accomplish this)
if(x_type!= "None") {

	//make the main video active
	selectImage(mainID);
	run("Reslice [/]...", "output=1.000 start=Bottom flip");
	// now i have a new stack
	// open: original + kymo-stack
	run("Z Project...", x_type_arg);
	// get the image ID
	XID=getImageID();
	rename("X: " + x_type);
	Stack.getDimensions(Xw, Xh, Xc, Xs, Xf);
	// open: original + kymo-slice + kymograph
	close("Reslice*");
}

// Make Y Kymograph

if(y_type!= "None") {

	//make the main video active
	selectImage(mainID);
	run("Reslice [/]...", "output=1.000 start=Left rotate");
	// now i have a new stack
	// open: original + kymo-stack
	run("Z Project...", y_type_arg);
	// get the image ID
	YID=getImageID();
	rename("Y: " + y_type);
	Stack.getDimensions(Yw, Yh, Yc, Ys, Yf);
	// open: original + kymo-slice + kymograph
	close("Reslice*");
}

// open at end of this section: 1) ORIGINAL + 2) KYMOGRAPH, to be yellow-lined'

// will close main video for now to increase the available memory to make the CONCATENATED image
close(fp_name);

//// TTL (Time-Tracer-Line) loop

// CONCATENATE
print(getValue("color.foreground"));
print(getValue("color.background"));
setLineWidth(1);
setForegroundColor(255, 255, 255);e
setColor(255);
print(getValue("color.foreground"));
print(getValue("color.background"));


///////// X-Kymo//////////
if(x_type!= "None") {

	selectImage(XID);
	
	makeLine(1, (Xh-1), Xw, (Xh-1));
	makeRectangle(Xh,0,0,400);
	changeValues(0,255,200);
	run("Flatten");
	// set the first flattened image equal to the soon-to-be accumulating concatenation
	AccX_ID = getImageID();
	rename("Concats-X!");
	
	for (i=2; i <= TILL; i++) {
		//make the X Kymograph active, that will have lines, iteratively, painted onto it
	    selectImage(XID);
	    Overlay.remove();
		makeLine(1, (Xh - i), Xw, (Xh - i));
		run("Flatten");
		// after Flatten, the newly-created & selected image will be ACTIVE
	    // This must be combined with the Accumulating line-series concatenation, and then deleted itself
	    run("Concatenate...", "  title=Concats-X! image1=[Concats-X!] image2=[" + getTitle + "]");
		
	}
}

// Y Kymo

if(y_type!= "None") {

	selectImage(YID);
	makeLine(30, 1, 30, 400);
	makeLine(1, 1, 1, Yh);
	run("Flatten");
	// set the first flattened image equal to the soon-to-be accumulating concatenation
	AccY_ID = getImageID();
	rename("Concats-Y!");

	
	for (i=2;i <= TILL; i++) {
		// make the Y Kymograph active, each time painting a line onto it
		selectImage(YID);
		// Ensure no lines from previous actions are pre-painted
		Overlay.remove();
		makeLine(i, 1, i, Yh);
		run("Flatten");
		run("Concatenate...", "  title=Concats-Y! image1=[Concats-Y!] image2=[" + getTitle + "]");
		
	}
}


// COMBINE
open(filepath); // the video is now active
videoName = getTitle();
//
print(videoName + "'s dimensions are...");
print("Time..." + getTime());
print("Height: " + getHeight());
print("Width: " + getWidth());
//

if(y_type!= "None") {
run("RGB Color");
run("Combine...", "stack1=" + videoName + " stack2=Concats-Y!");
videoName = getTitle();
}

if (x_type!= "None") {
run("RGB Color");
run("Combine...", "stack1=Concats-X! stack2=[" + videoName + "] combine");
videoName = getTitle();
}

//////////////////////////////////////////////////////////////////////////////////////////////////////

// Scratch-Pad


