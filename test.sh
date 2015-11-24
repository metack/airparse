clear
cucumber -q --tags ~@mtk_stress_test 2> /dev/null

if [ $? -eq 0 ]
then
  echo
  echo "Test completed successfully."
  exit 0
else
  echo
  echo "Test failed." >&2
  exit 1
fi

