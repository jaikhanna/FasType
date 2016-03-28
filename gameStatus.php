<?php
header("Content-Type: application/json");

	// $con=mysqli_connect("sql306.byethost7.com","b7_14583485","jaikhanna11397","b7_14583485_FasType");
$con=mysqli_connect("localhost","root","root","FasType");
	
		// Check connection
		if (mysqli_connect_errno($con))
		{
		  echo "Failed to connect to MySQL: " . mysqli_connect_error();
		}

	if($_GET['q'] == "update"){
		
		//code to update the player count
		$count = countRetrieval($con);

		$newCount = $count + 1;

		$increasePlayerCountQuery = sprintf("update gameStatus set playerCount = $newCount");
		$increasePlayerCountResult = mysqli_query($con, $increasePlayerCountQuery);

		echo "successfully updated!";
	}
	else if($_GET['q'] == "retrieve"){

		//code to retrieve the player count
		$count = countRetrieval($con);

		$resp = array("count" => $count);
		
		echo json_encode($resp);
	}
	else if($_GET['q'] == "clearAll"){

		//code to clear count
		$clearAllQuery = sprintf("update gameStatus set playerCount = 0");
		$clearAllResult = mysqli_query($con, $clearAllQuery);

		echo "successfully cleared!";
	}

	function countRetrieval($con){
		$countQuery = sprintf("select playerCount from gameStatus");
		$countResult = mysqli_query($con, $countQuery);
		$countResultArray = mysqli_fetch_array($countResult);
		return $countResultArray[0];
	}
?>