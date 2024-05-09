Param([string]$in, [string]$out="vtk", [switch]$h);		# Script parameters

if($h){													# Check if -h used
   $helpText='
Help - Usage: PsPly2Vtk [-h] [-in <String>] [-out <String>]
-h: This help :)
-in: Input file; The source to convert
-out: Output file; The destination vtk file';

    write-host($helpText);
    exit;
}


Write-host("Status - Check");

if ([string]::IsNullOrEmpty($in)) {						# Check if -in is empty
    Write-Host("Error - Use the -in <String> parameter!");
    exit;
}

$inputFile=$PSScriptRoot+"\"+$in;

if ( !(Test-Path $inputFile -PathType Leaf) ) {			# Check if -in's file is exists
        Write-Host("Error - File NOT found: $inputFile");
        exit;
    }




$format = $null;				# Loading the format of the file
$vertices = $null;				# The number of vertices
$faces = $null;					# The number of faces

$dataStart = 0;					# The line number of first data element; 
$invalidLineNumber = 0;			# The number of skipped lines



$fileLines = Get-Content -Path $inputFile 	# Get the lines as objects and store them in an array


$outLines = @();							# Empty array for output



$fileLines | ForEach-Object {				# Check specific data in array
	$line = $_;
	$number = $_.ReadCount;

	if ($line -match "^ply") { $format = $line.Split()[0]; }

	if ($line -match "^element vertex") { $vertices = [int]($line.Split()[2]); }
	if ($line -match "^element face") { $faces = [int]($line.Split()[2]); }
	if ($line -match "^end_header") { $dataStart = [int]($number+1); }
}



if ($format -eq "ply"){
	Write-host("Status - Converting");
	
	$outLines+="# vtk DataFile Version 2.0`nASCII`nDATASET POLYDATA";



	$outLines+="POINTS $vertices float";

	$fileLines | ForEach-Object {
		$line = $_;
		$number = $_.ReadCount;

		if ($number -ge $dataStart -and $number -le ($dataStart+$vertices+$invalidLineNumber-1)) {
			if($line -match "^#" -or $line -match "^$"){ $invalidLineNumber++; }
			else{
				$outLines+= $line;
			}
		}
	}

	   

	$outLines+="POLYGONS $faces 3";

	$fileLines | ForEach-Object {
		$line = $_;
		$number = $_.ReadCount;

		if ($number -ge ($dataStart+$vertices+$invalidLineNumber)) {
			if($line -match "^#" -or $line -match "^$"){ $invalidLineNumber++; }
			else{
				$outLines+= $line;
			}
		}
	}

	 try {
			$outLines;
			Set-Content -Path $PSScriptRoot\$out -Value $outLines;
			Write-host("Status - File generated");
		} 
	 catch {
			Write-host("Error - Generating failed");
		}


}
else{
		Write-host("Error - Are you sure this is a ply mesh file?");
		exit
	}

















