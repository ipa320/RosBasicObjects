#!/bin/bash
package_list=$@

function parserToRosModel(){    
    msg_desc=""
    for word in $1; do
        word="$(echo $word | sed -e 's/\[[^][]*\]/[]/g' )"
        if [[ $word == *"/"* ]]; then
            ref="$(echo $word | tr / .)"
            if [[ $ref = *"[]"* ]]; then
                msg_desc+='"'${ref%"[]"}'"[]'
            else
                msg_desc+='"'$ref'"'
            fi
        else
            msg_desc+=" "$word" "
        fi
    done
    echo $msg_desc
}

for p in $package_list
do
    cout_pkg=$((cout_pkg-1))
    specs_fullname=$(ros2 interface package $p)
    arr_specs=($specs_fullname)
    cout_specs=${#arr_specs[@]}

    echo $p':'
    echo '  specs:'

    for i in $specs_fullname
    do
        cout_specs=$((cout_specs-1))
        if [[ "$i" == *"/msg"* ]]; then
          message=${i/$p\/msg\//}
          message_show=$(ros2 interface show $i | grep -v '	' | grep -v '^#' )
          message_show="$(echo $message_show | sed -e 's/\s=\s/=/g')"
          final_desc=$(parserToRosModel "$message_show")
          echo -n '     msg: '$message
          echo $'\n''       message:'
          echo '         '$final_desc
        fi
        if [[ "$i" == *"/srv"* ]]; then
          service=${i/$p\/srv\//}
          service_show=$(ros2 interface show $i | grep -v '	' | grep -v '^#' )
          request="$(echo $service_show | sed 's/---.*//' | sed -e 's/\s=\s/=/g')"
          response="$(echo $service_show | sed -e 's#.*---\(\)#\1#'| sed -e 's/\s=\s/=/g')"
          final_request=$(parserToRosModel "$request")
          final_response=$(parserToRosModel "$response")   
          echo -n '     srv: '$service
          echo $'\n''       request:'
          if [ -n "$request" ];then
            echo '         '$final_request
          fi
          echo $'\n''       response:'
          if [ -n "$response" ];then
            echo '         '$final_response
          fi
        fi
    done
done

#	for i in $MsgsArray
#	do
#		if [[ "$i" =~ "ActionGoal" ]];then
#			ActionName=${i//'ActionGoal'/}
#			if [[ "${MsgsArray[@]}" =~ "${ActionName}ActionResult" ]] && [[ "${MsgsArray[@]}" =~ "${ActionName}ActionFeedback" ]]; then
#				arr_act+=$ActionName' '
#			fi
#		fi	
#	done
#	cout_act=${#arr_act[@]}
#    for i in $arr_act
#    do
#        cout_act=$((cout_act-1))
#	    echo -n '      ActionSpec '$i'{ goal { '$i'ActionGoal action_goal} result {'$i'ActionResult action_result} feedback {'$i'ActionFeedback action_feedback}}
#'
#        if (("$cout_act" >= "1"))
#        then
#            echo ','
#        fi
#    done
#
#    echo -n $'\n    }}'
#    if (("$cout_pkg" >= "1"))
#    then
#        echo ','
#    fi
#done
