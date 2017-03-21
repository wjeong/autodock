#encoding: utf-8

puts "
####################  AUTODOCK VINA MACRO  #####################
#                                                         
# FOLLOW BELOW STEPS              
#                                                         
# 1. VINA EXECUTIVE FILE MUST BELONG AT '..\\desktop\\autodock\\' 
# 2. ALL PDBQT FILES SHOULD BE IN THE SAME LOCATION
# 3. THIS RUBY EXECUTIVE FILE SHOULD BE LOCATIDED
#    IN THE SAME DIRECTORY WITH PDBQT
# 4. IF YOU DO NOT FOLLOW ABOVE INDICATIONS,
#    THE RESULTS WILL NOT BE GENERATED OR PROPER
#
################################################################

"

##### CHECK LIBRARY AND LOAD LIBRARY #####
# check os gem whether installed or not
chkGem = `gem list -l os`

if chkGem.size > 1
	require 'os'
else
	puts "INSTALLING LIBRARY."
	`gem install os`
	puts "DONE."
	
	require 'os'
end


##### DETECT OS TYPE #####
# check an operating system is mac? or not
os = OS.windows?


##### SET AUTODOCK VINA EXECUTIVE FILE #####
# set autodock vina executive file location
begin
	# in case of OS is windows
	if os == true
		autodockDirPath = Dir["c:/users/*/desktop/autodock/"][0]
		autodockPath    = autodockDirPath + "vina.exe"
	# in case of OS is mac
	else
		autodockDirPath = Dir["/Users/*/Desktop/autodock/"][0]
		autodockPath    = autodockDirPath + "./vina"
	end
	
	# check autodock file exist
	unless File.exist?(autodockPath.gsub("./", ""))
		# terminate code
		abort ">> ! NO AUTODOCK EXECUTIVE FILE FOUND."
	end
rescue
	# in case of no autodock directory
	# terminate code
	abort ">> ! NO AUTODOCK DIRECTORY FOUND."
end


##### SEARCH PDBQT FILE #####
# make list of all pdbqt files
allPdbqt = Dir["*.pdbqt"]

# in case of no pdbqt file is there,
if allPdbqt.size == 0
	# terminate code
	abort ">> ! NO PDBQT FOUND."
end


##### GET/SET RECEPTOR #####
# user input, receptor file name
puts "> INPUT RECEPTOR FILE NAME, e.g. 3k4d.pdbqt"
receptor = gets.chomp

# if user input invalid format or inexist file name
unless File.exist?(receptor)
	until File.exist?(receptor) == true
		puts ">> ! CAN NOT FIND RECEPTOR FILE. ENTER AGAIN."
		receptor = gets.chomp
	end
	puts ">> #{receptor} FILE FOUND."
else
	puts ">> #{receptor} FILE FOUND."
end


##### CHECK LIGANDS EXISTANCE #####
# remove receptor element from all pdbqt list, which will be a file list of all ligands
ligands  = allPdbqt - [receptor]

# check ligands existance
if ligands.size == 0
	abort ">> NO LIGAND FOUND."
else
	puts ">> #{ligands.size} LIGANDS FOUND."
end
puts ""


##### SET GRIDBOX CENTER COORDINATION #####
# user input, gridbox center coordinations
puts "> INPUT CENTER COORDINATION OF GRIDBOX SEPARATED BY #. e.g. 1.1#2.2#3.3"
gridboxCenter = gets.chomp.split("#").map{|e| e.to_f}

# if the user input invalid format of gridbox center coordination
if gridboxCenter.size != 3
	until gridboxCenter.size == 3
		puts ">> ! INVALID COORDINATION FORMAT. ENTER AGAIN. e.g. 1.1#2.2#3.3"
		gridboxCenter = gets.chomp.split("#").map{|e| e.to_f}
	end
	puts ">> center_x = #{gridboxCenter[0]}\n   center_y = #{gridboxCenter[1]}\n   center_z = #{gridboxCenter[2]}"
else
	puts ">> center_x = #{gridboxCenter[0]}\n   center_y = #{gridboxCenter[1]}\n   center_z = #{gridboxCenter[2]}"
end
puts ""


##### SET GRIDBOX SIZE #####
# user input, gridbox size
puts "> INPUT THE SIZE OF GRIDBOX THAT SHOULD BE SEPARATED BY #. e.g. 14#8#12"
gridboxSize = gets.chomp.split("#").map{|e| e.to_f}

# if the user input invalid format of gridbox size
if gridboxSize.size != 3
	until gridboxSize.size == 3
		puts ">> ! INVALID SIZE FORMAT. ENTER AGAIN. e.g. 14#8#12"
		gridboxSize = gets.chomp.split("#").map{|e| e.to_f}
	end
	puts ">> size_x = #{gridboxSize[0]}\n   size_y = #{gridboxSize[1]}\n   size_z = #{gridboxSize[2]}"
else
	puts ">> size_x = #{gridboxSize[0]}\n   size_y = #{gridboxSize[1]}\n   size_z = #{gridboxSize[2]}"
end
puts ""
puts ""
puts ""
puts "> CHECK YOUR OPTIONS."
puts ""
puts "--receptor #{receptor}"
puts "--ligand   #{ligands.size} LIGANDS"
puts ""
puts "--center_x #{gridboxCenter[0]}"
puts "--center_y #{gridboxCenter[1]}"
puts "--center_z #{gridboxCenter[2]}"
puts ""
puts "--size_x   #{gridboxSize[0]}"
puts "--size_y   #{gridboxSize[1]}"
puts "--size_z   #{gridboxSize[2]}"
puts ""
puts "> CONTINUE... PRESS ENTER."
cont = gets

unless cont == "\n"
	abort "> CODE TERMINATED BY USER"
end


##### MAKE CONFIGURATION TXT FILE #####
# write configuration file that includes the center coordination and size of gridbox an user input
confName = Time.new.strftime("conf_%Y%m%d_%H%M%S.txt") # set conf file name
File.open(confName, "wb") do |f|
	cont = "center_x = #{gridboxCenter[0]}\ncenter_y = #{gridboxCenter[1]}\ncenter_z = #{gridboxCenter[2]}\n\nsize_x = #{gridboxSize[0]}\nsize_y = #{gridboxSize[1]}\nsize_z = #{gridboxSize[2]}"
	f << cont
end


##### RUN DOCKING PRECESS #####
# set configuration file path
confPath = Dir.pwd + "/conf.txt"

# for process status
i, totalNum = 1, ligands.size

# timestamp for log and output
timestamp = confName.gsub("conf_", "").gsub(".txt", "")

# run docking process with autodock vina
ligands.each do |lig|
	
	# set output file name and path
	output = lig.gsub(".pdbqt", "_#{timestamp}.pdbqt")
	
	# set log file name and path
	log    = lig.gsub(".pdbqt", "_#{timestamp}.log")
	
	# executive code
	puts lig
	
	`"#{autodockPath}" --receptor "#{receptor}" --ligand "#{lig}" --out "#{output}" --log "#{log}" --config "#{confName}"`

	# print process status
	puts "#{i} / #{totalNum}"
	
	# for process status
	i += 1
end

puts "ALL DONE."
