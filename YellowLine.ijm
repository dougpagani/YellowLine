//Fiji_MultiKymographMovie
//2016 Jan 17 Jeff Bouffard 

//Generates single movie featuring time series and kymographs in both directions
//yellow line traces time in kymographs while movie plays
//Input: Movie processed by Fiji_Process_GCaMP.  Currently only _A
//Output: Movie with kymographs

//-----------------------------------------------------------------------------------------------------------
//In this macro frames are slices because Fiji seems to want to treat frames as slices in 3D movies
//I successfully corrected it in Fiji_Process_GCaMP_1_1, but it is detrimental because there isn't a command to get the frame number

//----------------------------------------------------------------------------------------
//Clearing Fiji of all open images and windows
waitForUser("SAVE ANY FILES YOU WANT TO KEEP!!!","All images and windows open in Fiji will be closed when you press OK! \nSave any images or files you wish to keep.");

//next line lifted from http://rsb.info.nih.gov/ij/macros/Close_All_Windows.txt
while (nImages>0) {selectImage(nImages); close();}
//next line lifted from http://imagej.1557.x6.nabble.com/Result-window-in-macro-td3698804.html
if (isOpen("Results")) {selectWindow("Results"); run("Close");}

if(isOpen("ROI Manager")){selectWindow("ROI Manager");run("Close");}
if(isOpen("Log")){selectWindow("Log");run("Close");}
if(isOpen("Debug")){selectWindow("Debug");run("Close");}

//----------------------------------------------------------------------------------------
//Opening and gathering information from movie file
filepath=File.openDialog("Select a File");
print(filepath); //if you want to see the filepath in log window
open(filepath);

title = getTitle();
titleID = getImageID();
Stack.getDimensions(width,height,channel,slice,frame);

SplitString = split(title,"."); 
print(SplitString[0]); //if you want to see SplitString in log window

SplitFilepath = split(filepath, File.separator);

// Makes directory from File path for finding the associated Kymographs in the directory
Directory = "/";
for(i = 0; i < (lengthOf(SplitFilepath) - 1); i++) {
Directory = Directory + SplitFilepath[i]+ File.separator;};

print(Directory); //if you want to see Directory in log window

//----------------------------------------------------------------------------------------
//Defining kymograph folder
KymographDirectory = Directory+"Kymographs"+File.separator;
print("KymographDirectory:" + KymographDirectory);

//If kymograph data doesn't exist, error is thrown to user.
if (File.isDirectory(KymographDirectory)!=1) {
    exit("Kymographs not found for this movie. \nPlease run Fiji_KymoCalcium_GCaMP to generate kymographs for this script. \nGoodbye. ");};

//----------------------------------------------------------------------------------------
//Loading kymographs
//AvgX 
NewTitle_AvgKymoX = SplitString[0]+"_AvgKymoX.tif";
open(KymographDirectory+NewTitle_AvgKymoX);
AvgKymoX=getImageID(); 

//MaxY
NewTitle_MaxKymoY = SplitString[0]+"_MaxKymoY.tif";
open(KymographDirectory+NewTitle_MaxKymoY);
MaxKymoY=getImageID();

//----------------------------------------------------------------------------------------
//Defining folders to save individual marked frames to assemble into movie
AvgKymoX_Directory = KymographDirectory+"AvgKymoX"+File.separator;
	//If folder doesn't exist then it is created.
if (File.isDirectory(AvgKymoX_Directory)!=1) {File.makeDirectory(AvgKymoX_Directory);};

MaxKymoY_Directory = KymographDirectory+"MaxKymoY"+File.separator;
	//If folder doesn't exist then it is created.
if (File.isDirectory(MaxKymoY_Directory)!=1) {File.makeDirectory(MaxKymoY_Directory);};

//----------------------------------------------------------------------------------------
//
tLine_AvgKymoX = NewTitle_AvgKymoX+"_tLine";	
tLine_MaxKymoY = NewTitle_MaxKymoY+"_tLine";
setLineWidth(1);

for (i=0; i<slice; i++){
selectImage(AvgKymoX);
makeLine(0, (slice-i), width, (slice-i), 1);
run("Flatten");
saveAs("Tiff",AvgKymoX_Directory+tLine_AvgKymoX+"_"+i);
close();

selectImage(MaxKymoY);
makeLine(i, 0, i, height, 1);
run("Flatten");
saveAs("Tiff",MaxKymoY_Directory+tLine_MaxKymoY+"_"+i);
close();
};

exit("Script complete. \nDrag folder to Fiji toolbar to load movie. \nGoodbye. ");


