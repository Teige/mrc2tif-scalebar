#/bin/bash
#Script to convert MRC files to TIF and add a scale bar automatically.

#Scale bar options

#scale bar colour
colour="white"

#scale length is 200nm 
scale_length_nm=200



for mrc_file in *.mrc;
do
	base_name=$(echo $mrc_file | sed 's|.mrc||g')
	
	#image size
	image_x=$(header $mrc_file | grep "Start cols" | awk '{print $11}')
	#echo "image x is $image_x"
	image_y=$(header $mrc_file | grep "Start cols" | awk '{print $12}')
	#echo "image y is $image_y"

	#position
	#lower left
	scale_position_y=$(bc <<< $image_y*0.95)
	#echo "scale position y is $scale_position_y"
	scale_start=$(bc <<< $image_x*0.07)
	#echo "scale x start position is $scale_start" 
	text_position_y=$(bc <<< $image_y*0.98)	
	#echo "text position y is $text_position_y"
	text_start=$(bc <<< $image_x*0.09)

	#scale bar size determination

	#get image pixel size from the MRC file header
	image_apix=$(header $mrc_file | grep "Pixel" | awk '{print $4}')
	#echo "image apix is $image_apix"

	#multiply image apix by 1000 to ensure integers for bash less than greather than conditions
	int_apix=$(echo "(($image_apix*1000)+0.5)/1" | bc)
	#echo "apix times one thousand as integer is $int_apix"
	if [ $int_apix -lt 1600 ] ; then
		scale_length_nm=50
	elif [ $int_apix -lt 3200 ] ;
		then scale_length_nm=100
	elif [ $int_apix -lt 5000 ] ;
		then scale_length_nm=200
	elif [ $int_apix -lt 8000 ] ;
		then scale_length_nm=500
	elif [ $int_apix -lt 16000 ] ;
		then scale_length_nm=1000
	elif [ $int_apix -le 32000 ] ;
		then scale_length_nm=2000
	elif [ $int_apix -gt 32000 ] ;
		then scale_length_nm=10000
	
	fi
	printf "image apix is $image_apix\nscale bar size is $scale_length_nm nm\n"

	image_nmpix=$(bc <<< $image_apix*0.1)
	#echo "image nm per pixel is $image_nmpix"
	scale_length_pix=$(bc <<< ${scale_length_nm}/${image_nmpix})
	#echo "scale bar length of $scale_length_nm nm in pixels is $scale_length_pix"
	scale_end=$(bc <<< ${scale_start}+${scale_length_pix})
	#echo "scale x end position is $scale_end"

	#convert MRC to TIF
	mrc2tif -C 60,180 $base_name.mrc $base_name.tif

	#add scale bar
	convert $base_name.tif -fill black -stroke $colour -strokewidth 50 -draw "line ${scale_start},${scale_position_y},${scale_end},${scale_position_y}" -font Open-Sans-Bold -pointsize 75 -fill $colour -strokewidth 1 -annotate +${text_start}+${text_position_y} "$scale_length_nm nm" ${base_name}_scalebar.tif

done



