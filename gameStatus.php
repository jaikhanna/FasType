<?php
header("Content-Type: application/json");
	//byethost
	// $con=mysqli_connect("sql306.byethost7.com","b7_14583485","jaikhanna11397","b7_14583485_FasType");
	
	//localhost
	// $con=mysqli_connect("localhost","root","root","FasType");
	
	//heroku
	$con=mysqli_connect("us-cdbr-iron-east-03.cleardb.net","bfe09474ff428a", "7ad3aee5","heroku_2f2f75a7672a608");
	
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

		//clear gameStatus
		$clearAllQuery = sprintf("update gameStatus set playerCount = 0");
		$clearAllResult = mysqli_query($con, $clearAllQuery);

		//clear questionstring
		// $truncateQuery = sprintf("truncate table questionstring");
		// $truncateResult = mysqli_query($con,$truncateQuery);
		$clearVal = "notSetYet";
		// $clearQuestionStringQuery = sprintf("insert into questionstring values('$clearVal')");
		//try update query
		$clearQuestionStringQuery = sprintf("update questionstring set randomQuestionSentence = '$clearVal' ");
		$clearQuestionStringResult = mysqli_query($con, $clearQuestionStringQuery);

		// echo "successfully cleared!";

		$returnString = array("cleared" =>  "cleared everything here!");
	
		echo json_encode($returnString);
	}
	else if($_GET['q'] == "getQuestion"){

		//check if sentence is already set
		$checkSentenceStatusQuery = sprintf("select randomQuestionSentence from questionstring");
		$checkSentenceStatusResult = mysqli_query($con, $checkSentenceStatusQuery);
		$currentSentenceStatus = mysqli_fetch_array($checkSentenceStatusResult);

		if($currentSentenceStatus[0] == "notSetYet" || empty($currentSentenceStatus[0])){

			//set the sentence for the current game
			$randomSentence = createRandomSentence();


			$truncateQuery = sprintf("truncate table questionstring");
			$truncateResult = mysqli_query($con,$truncateQuery);

			$updateQuestionSentenceQuery = sprintf("insert into questionstring values('$randomSentence')");
			$updateQuestionSentenceResult = mysqli_query($con, $updateQuestionSentenceQuery);

		}

		$retrieveRandomStringQuery = sprintf("select randomQuestionSentence from questionstring");
		$retrieveRandomStringResult = mysqli_query($con, $retrieveRandomStringQuery);
		$stringArray = mysqli_fetch_array($retrieveRandomStringResult);

		// echo $stringArray[0];
		$returnString = array("randomQuestionSentence" =>  $stringArray[0]);
	
		echo json_encode($returnString);		
	}

	function countRetrieval($con){
		$countQuery = sprintf("select playerCount from gameStatus");
		$countResult = mysqli_query($con, $countQuery);
		$countResultArray = mysqli_fetch_array($countResult);
		return $countResultArray[0];
	}



function createRandomSentence(){

	$levels = array('kids', 'intermediates', 'champs');
	$currentLevel = $levels[findRandomIndex($levels)];

	$sentence = 'if you see this => an error occurred';

	if($currentLevel == 'kids'){
		$sentence = kidsString();
	}
	else if($currentLevel == 'intermediates'){
		$sentence = intermediatesString();
	}
	else if($currentLevel == 'champs'){
		$sentence = champsString();
	}
	 
	return $sentence;
    }
    
function findRandomIndex($item){
        $randomIndex = rand(0, count($item) -1);
        return $randomIndex;
}


function kidsString() {

	$sentence = '';

	$art = array("the", "my", "your", "our", "that", "this", "every", "one", "the only", "his", "her");


	$adj = array("happy", "rotating", "red", "fast", "elastic", "smily", "unbelievable", "infinte", "surprising", "mysterious", "glowing", "green", "blue", "tired", "hard", "soft", "transparent", "long", "short", "excellent", "noisy", "silent", "rare", "normal", "typical", "living", "clean", "glamorous", "fancy", "handsome", "lazy", "scary", "helpless", "skinny", "melodic", "silly", "kind", "brave", "nice", "ancient", "modern", "young", "sweet", "wet", "cold", "dry", "heavy", "industrial", "complex", "accurate", "awesome", "shiny", "cool", "glittering", "fake", "unreal", "naked", "intelligent", "smart", "curious", "strange", "unique", "empty", "gray", "saturated", "blurry");


	$noun = array("forest", "tree", "flower", "sky", "grass", "mountain", "car", "computer", "man", "woman", "dog", "elephant", "ant", "road", "butterfly", "phone", "computer program", "grandma", "school", "bed", "mouse", "keyboard", "bicycle", "spaghetti", "drink", "cat", "t-shirt", "carpet", "wall", "poster", "airport", "bridge", "road", "river", "beach", "sculpture", "piano", "guitar", "fruit", "banana", "apple", "strawberry", "rubber band", "saxophone", "window", "linux computer", "skate board", "piece of paper", "photograph", "painting", "hat", "space", "fork", "mission", "goal", "project", "tax", "wind mill", "light bulb", "microphone", "cpu", "hard drive", "screwdriver");


	$pre = array("under", "in front of", "above", "behind", "near", "following", "inside", "besides", "unlike", "like", "beneath", "against", "into", "beyond", "considering", "without", "with", "towards");


	$verb = array("sings", "dances", "was dancing", "runs", "will run", "walks", "flies", "moves", "moved", "will move", "glows", "glowed", "spins", "promised", "hugs", "cheated", "waits", "is waiting", "is studying", "swims", "travels", "traveled", "plays", "played", "enjoys", "will enjoy", "illuminates", "arises", "eats", "drinks", "calculates", "kissed", "faded", "listens", "navigated", "responds", "smiles", "will smile", "will succeed", "is wondering", "is thinking", "is", "was", "will be", "might be", "was never");

	$sentence .= $art[findRandomIndex($art)]." ";
	$sentence .= $adj[findRandomIndex($adj)]." ";
	$sentence .= $noun[findRandomIndex($noun)]." ";
	$sentence .= $verb[findRandomIndex($verb)]." ";
	
	$sentence .= $pre[findRandomIndex($pre)]." ";
	$sentence .= $art[findRandomIndex($art)]." ";
	$sentence .= $adj[findRandomIndex($adj)]." ";
	$sentence .= $noun[findRandomIndex($noun)];

	return $sentence;
}

function intermediatesString() {
	
	$quesStringLength = rand(30, 40);
	$spaceLoc = rand(3,7);

	$qwertyVals[0][0] = '1';
	$qwertyVals[0][1] = 'q';
	$qwertyVals[0][2] = 'a';
	$qwertyVals[0][3] = 'z';
	
	$qwertyVals[1][0] = '2';
	$qwertyVals[1][1] = 'w';
	$qwertyVals[1][2] = 's';
	$qwertyVals[1][3] = 'x';

	$qwertyVals[2][0] = '3';
	$qwertyVals[2][1] = 'e';
	$qwertyVals[2][2] = 'd';
	$qwertyVals[2][3] = 'c';

	$qwertyVals[3][0] = '4';
	$qwertyVals[3][1] = 'r';
	$qwertyVals[3][2] = 'f';
	$qwertyVals[3][3] = 'v';

	$qwertyVals[4][0] = '5';
	$qwertyVals[4][1] = 't';
	$qwertyVals[4][2] = 'g';
	$qwertyVals[4][3] = 'b';

	$qwertyVals[5][0] = '6';
	$qwertyVals[5][1] = 'y';
	$qwertyVals[5][2] = 'h';
	$qwertyVals[5][3] = 'n';

	$qwertyVals[6][0] = '7';
	$qwertyVals[6][1] = 'u';
	$qwertyVals[6][2] = 'j';
	$qwertyVals[6][3] = 'm';

	$qwertyVals[7][0] = '8';
	$qwertyVals[7][1] = 'i';
	$qwertyVals[7][2] = 'k';
	$qwertyVals[7][3] = ',';

	$qwertyVals[8][0] = '9';
	$qwertyVals[8][1] = 'o';
	$qwertyVals[8][2] = 'l';
	$qwertyVals[8][3] = '.';

	$qwertyVals[9][0] = '0';
	$qwertyVals[9][1] = 'p';
	$qwertyVals[9][2] = ';';
	$qwertyVals[9][3] = '/';

	$qwertyVals[10][0] = '-';
	$qwertyVals[10][1] = ':';
	$qwertyVals[10][2] = '?';
	$qwertyVals[10][3] = '(';

	$qwertyVals[11][0] = '$';
	$qwertyVals[11][1] = '!';
	$qwertyVals[11][2] = ')';
	$qwertyVals[11][3] = "'";

	$keyboardDist = rand(5,10); 

	$x1 = rand(0,11);
	$y1 = rand(0,3);

	$sentence = $qwertyVals[$x1][$y1];

	for ($i = 0; $i < $quesStringLength; $i++) { 
		
		if($i == $spaceLoc){
			$sentence .= ' ';
			$spaceLoc += rand($i + 2, $i + rand(4,7));	
			continue;
		}
		else{
			//equation - !!
			//following x = (-b +/- sqrt(b^2 - 4ac))/2a   - taking 'a' as always '1' (that's how I formed the equation)

			$y2 = rand(0,3);
			$b = 2*$x1;
			$c = pow($x1,2) + pow(($y1- $y2), 2) - pow($keyboardDist, 2);

			$x2 = abs(floor((-$b + sqrt(pow($b, 2) - 4*$c) )/2));

			$sentence .= $qwertyVals[$x2][$y2];
			$x1 = $x2;
			$y1 = $y2;
		}
	}

	return $sentence;
}



function champsString() {

	$quesStringLength = rand(30, 40);
	$chars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.,-/:;()$&@\"\'?![]{}#%^*+=_|~<>';
	$sentence = '';
	$charsLen = strlen($chars);
	$spaceLoc = rand(3,7);

	for ($i = 0; $i < $quesStringLength; $i++) {

		if($i == $spaceLoc){
			$sentence .= ' ';
			$spaceLoc += rand($i + 2, $i + rand(4,7));	
			continue;
		}

		$sentence .= $chars[rand(0, $charsLen - 1)];
	}

	return $sentence;
}
?>