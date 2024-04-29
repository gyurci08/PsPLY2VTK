$inputFileName = "ply";


# Loading the format of the file
$format = $null;
# The number of vertices
$vertices = $null;
# The number of faces
$faces = $null;

$dataStart = 100;
$invalidLineNumber = 0;


# Read the file line by line
$fileLines = Get-Content -Path $inputFileName 


$outLines = @()



$fileLines | ForEach-Object {
    $line = $_;
    $number = $_.ReadCount;

    if ($line -match "^ply") { $format = $line.Split()[0]; }

    if ($line -match "^element vertex") { $vertices = [int]($line.Split()[2]); }
    if ($line -match "^element face") { $faces = [int]($line.Split()[2]); }
    if ($line -match "^end_header") { $dataStart = [int]($number+1); }
}


if ($format -ne "ply") { exit }
else{
    $outLines+="# vtk DataFile Version 2.0`nASCII`nDATASET POLYDATA"



    $outLines+="POINTS $vertices float"
    
    $fileLines | ForEach-Object {
        $line = $_;
        $number = $_.ReadCount;

        if ($number -ge $dataStart -and $number -le ($dataStart+$vertices+$invalidLineNumber-1)) {
                    if($line -match "^#" -or $line -match "^$"){ $invalidLineNumber++; }
                    else{
                        $outLines+= $line
                    }
                
        }
     }

   

    $outLines+="POLYGONS $faces 3"   

    $fileLines | ForEach-Object {
        $line = $_;
        $number = $_.ReadCount;

        if ($number -ge ($dataStart+$vertices+$invalidLineNumber)) {
                    if($line -match "^#" -or $line -match "^$"){ $invalidLineNumber++; }
                    else{
                        $outLines+= $line
                    }
                
        }
     }


     $outLines;
     Set-Content -Path "vtk" -Value $outLines;



}

















