#! /bin/sh

dir=$(cd "$(dirname "$0")" || exit; pwd)
# shellcheck disable=SC2039
source "${dir}"/../loopForDuplicateImages.sh

test_validUsage_ok(){
  validUsage OneParam SecondParam >>"${stdoutF}" 2>>"${stderrF}"
  got=$?
  assertEquals "Bad return code" "${SHUNIT_TRUE}"  $got
}

test_validUsage_empty(){
  validUsage >>"${stdoutF}" 2>>"${stderrF}"
  got=$?
  assertNotEquals "Bad return code" "${SHUNIT_TRUE}"  $got
}

test_validUsage_w_3Params_error(){
  validUsage OneParam TwoParam ThirthParam >>"${stdoutF}" 2>>"${stderrF}"
  got=$?
  assertNotEquals "Bad return code" "${SHUNIT_TRUE}"  $got
}

test_validUsage_w_3Params_ok_nolog(){
  validUsage OneParam TwoParam --nolog >>"${stdoutF}" 2>>"${stderrF}"
  got=$?
  assertEquals "Bad return code" "${SHUNIT_TRUE}"  $got
}

test_validUsage_w_3Params_ok_enablelog(){
  validUsage OneParam TwoParam --enablelog >>"${stdoutF}" 2>>"${stderrF}"
  got=$?
  assertEquals "Bad return code" "${SHUNIT_TRUE}"  $got
}

test_validExistingPath_ok(){
  validExistingPath "${outputDir}" >>"${stdoutF}" 2>>"${stderrF}"
  got=$?
  assertEquals "Bad return code" "${SHUNIT_TRUE}"  $got
}

test_validExistingPath_empty(){
  validExistingPath >>"${stdoutF}" 2>>"${stderrF}"
  got=$?
  assertNotEquals "Bad return code" "${SHUNIT_TRUE}"  $got
}

test_validExistingPath_w_2Params(){
  validExistingPath "/tmp" "dummy_path" >>"${stdoutF}" 2>>"${stderrF}"
  got=$?
  assertEquals "Bad return code" "${SHUNIT_TRUE}"  $got
}

test_validExistingPath_w_3Params(){
  validExistingPath "/tmp" "dummy_path" "extraParam" >>"${stdoutF}" 2>>"${stderrF}"
  got=$?
  assertNotEquals "Bad return code" "${SHUNIT_TRUE}"  $got
}

test_validExistingPath_invalid(){
  validExistingPath "${dummyDir}x" >>"${stdoutF}" 2>>"${stderrF}"
  got=$?
  assertNotEquals "Bad return code" "${SHUNIT_TRUE}"  $got
}

test_getFileSize_ok(){
  got=$(getFileSize "$dummyDir/dummy_file.txt")
  echo "File size ${got} "
  assertTrue "File Size" "[ ${got} -gt 0 ]"
}

test_getFileSize_empty(){
  got=$(getFileSize)
  assertFalse "File Size" "[ ${got} -gt 0 ]"
}

test_getFileSize_error(){
  got=$(getFileSize "$dummyDir/non_file.txt")
  assertFalse "File Size" "[ ${got} -gt 0 ]"
}

test_convertImage_empty(){
  convertImage  >>"${stdoutF}" 2>>"${stderrF}"
  got=$?
  assertNotEquals "Bad return code" "${SHUNIT_TRUE}"  $got
}

test_convertImage_w_2param_error(){
  convertImage OneParam.jpg TwoParam.jpg >>"${stdoutF}" 2>>"${stderrF}"
  got=$?
  assertNotEquals "Bad return code" "${SHUNIT_TRUE}"  $got
}

test_convertImage_w_2param_ok(){
  convert -size 32x32 xc:white "$dummyDir/empty1.jpg"
  convertImage "$dummyDir/empty1.jpg" "$dummyDir/empty1_converted.jpg" >>"${stdoutF}" 2>>"${stderrF}"
  got=$?
  assertEquals "Bad return code" "${SHUNIT_TRUE}"  $got
}


############################################################################ Overwrite
#https://angelesbroullon.gitlab.io/code-notepad/2020/10/08/shunit2-function-reference/
#https://programmerclick.com/article/48711826008/
oneTimeSetUp() {
  echo ">>oneTimeSetUp"
  outputDir="../../output_test"
  dummyDir="/tmp/dummy_path"
  if [ ! -d "$outputDir" ]; then
    mkdir "$outputDir"
  else
    echo "Check the results at ${outputDir}..."
  fi
  stdoutF="${outputDir}/stdout"
  stderrF="${outputDir}/stderr"
  printf "############################### %s\n" "$(date)" >>"${stdoutF}"

  if [ ! -d "$dummyDir" ]; then
    mkdir "$dummyDir"
    echo "dummy" > "$dummyDir/dummy_file.txt"
  fi
}

oneTimeTearDown(){
  if [ -d "$dummyDir" ]; then
    rm -rf "$dummyDir"
  fi
}

######################## Main
c=$(eval 'which shunit2')
if [ -n "$c" ]; then
  eval . "$c"
fi
