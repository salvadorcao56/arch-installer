
export LANG=es_ES.UTF-8
ejecutar ()
{
  archivo=$( echo $1 | cut -d "." -f1 )
  extension=$( echo $1 | cut -d "." -f2 )
  conjunto=$archivo$extension
  if [ -f $1 ] ; then
    case $1 in
      *.py)   clear && python $1   ;;
      *.js)   clear && node $1   ;;
      *.c)    clear && gcc $1 -o $archivo -w -lm && ./$archivo && read && rm $archivo;;
      *.cpp)  clear && g++ $1 -o $archivo -w -lm && ./$archivo && read && rm $archivo;;
      *.java) clear && java $1 && read && rm $archivo.class;;
      *.scala) clear && scalac $1 && scala $archivo && read && rm $archivo.class;;
      *.sh)   clear && bash $1;;
      *.cs)   clear && dotnet run $1;;
      *.go)   clear && go build $1 && ./$archivo && read && rm $archivo;;
      *.hs)   clear && ghci $1;;
      *.html) clear && firefox $1;;
      *.rs)   clear && rustc $1 && ./$archivo && read && rm $archivo;;
      *.exs)  clear && elixir $1 ;;
      *.rb)   clear && ruby $1 ;;
      *.kt)   clear && kotlinc $1 -include-runtime -d $archivo.jar && java -jar $archivo.jar && rm $archivo.jar;;
      *)      echo "'$1' No tengo rutina de ejecución para este tipo de archivo" ;;
    esac
  else
    echo "'$1' archivo No válido"
  fi
}

debug ()
{
  archivo=$( echo $1 | cut -d "." -f1 )
  extension=$( echo $1 | cut -d "." -f2 )
  if [ -f $1 ] ; then
    case $1 in
      #*.py)   clear && python $1   ;;
      *.c)    clear && gcc $1 -o $archivo -w -lm -g && gdb $archivo && read && rm $archivo;;
      *.cpp)  clear && g++ $1 -o $archivo -w -lm -g && gdb $archivo && read && rm $archivo;;
      *.java) clear && javac $1 -g && jdb $archivo && read && rm $archivo.class;;
      *.sh)   clear && bash $1+x;;
      # *.cs)   clear && dotnet run $1;;
      # *.go)   clear && go build $1 && ./$archivo && read && rm $archivo;;
      # *.hs)   clear && ghci $1;;
      # *.html) clear && firefox $1;;
      # *.rs)   clear && rustc $1 && ./$archivo && read && rm $archivo;;
      # *.exs)  clear && elixir $1 ;;
      # *.rb)   clear && ruby $1 ;;
      # *.kt)   clear && kotlinc $1 -include-runtime -d $archivo.jar && java -jar $archivo.jar && rm $archivo.jar;;
      *)      echo "'$1' No tengo rutina de ejecución para este tipo de archivo" ;;
    esac
  else
    echo "'$1' archivo No válido"
  fi
}

# nuevo_proyecto_c#()
# {
#   dotnet new console -o $1
# }

# ejecutar_proyecto_c#()
# {
#   dotnet run
# }

descomprimir ()
{
  archivo=$( echo $1 | cut -d "." -f1 )
  if [ -f $1 ] ; then
    case $1 in
      *.tar.gz)     tar -xzvf $1 ;;
      *.tar.bz2)    bzip2 -dc $1 | tar-xv ;;
      *.gz)         gzip -d $1   ;;
      *.bz2)        bzip2 -d $1  ;;
      *.zip)        unzip $1 ;;
      *.rar)        rar -x $1 ;;
      *)      echo "'$1' No tengo rutina de ejecución para este tipo de archivo" ;;
    esac
  else
    echo "'$1' archivo No válido"
  fi
}

comprimir ()
{
  archivo=$( echo $1 | cut -d "." -f1 )
  read -p "¿En que formato(gz,bz2,tar.gz,tar.bz2,zip,rar)?" op
  # if [ -f $1 ] ; then
    case $op in
      gz)         gzip -9 $1   ;;
      bz2)        bzip $1  ;;
      tar)     tar -czfv $1.tar $1 ;;
      tar.bz2)    tar -c $1 | bzip2 > $archivo.tar.bz2 ;;
      zip)        zip -r $1.zip $1 ;;
      rar)      rar -a $1 ;;
      *)      echo "'$1' No tengo rutina de ejecución para este tipo de archivo" ;;
    esac
  # else
  #   echo "'$1' archivo No válido"
  # fi
}

# pulseaudio
pa-list() { pacmd list-sinks | awk '/index/ || /name:/' ;}
pa-set() { 
	# list all apps in playback tab (ex: cmus, mplayer, vlc)
	inputs=($(pacmd list-sink-inputs | awk '/index/ {print $2}')) 
	# set the default output device
	pacmd set-default-sink $1 &> /dev/null
	# apply the changes to all running apps to use the new output device
	for i in ${inputs[*]}; do pacmd move-sink-input $i $1 &> /dev/null; done
}
pa-playbacklist() { 
	# list individual apps
	echo "==============="
	echo "Running Apps"
	pacmd list-sink-inputs | awk '/index/ || /application.name /'

	# list all sound device
	echo "==============="
	echo "Sound Devices"
	pacmd list-sinks | awk '/index/ || /name:/'
}
pa-playbackset() { 
	# set the default output device
	pacmd set-default-sink "$2" &> /dev/null
	# apply changes to one running app to use the new output device
	pacmd move-sink-input "$1" "$2" &> /dev/null
}
fix() {
  local output
  output=$("$@" 2>&1)
  echo "$output"
  opencode run "arregla este error: $output"
}
