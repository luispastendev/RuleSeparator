<?php
// $test = "asdfasd fasd fsadf f asdf as~dfsd sadf ff sdfasf asfsafasfasfafa fasfasfasfasdf asfasfasfasfasfasf fasfasfasfasfasfasfsafasfasd";
$test = "How do I take the string and, split it 2 into a table of strings? asdfasdff sdfsdf";
// asdfasd
// fasd fsadf
// f asdf
// asdfsdf
// sadf
$s = explode(' ', $test);

$limit = 20;
$macros = [""];
$block = 0;

foreach ($s as $key => $value) {
    
    if(strlen($macros[$block]) < $limit){   

        $tmp = $macros[$block] . newMacroOrSpace($macros[$block]) . $value;

        if (strlen($tmp) <= $limit) {

            $macros[$block] = $tmp; // store in block
            continue;
        } 

        $block++;
        $macros[$block] = newMacroOrSpace($macros[$block]) . $value;

    } else {

        $block++;
        $macros[$block] = newMacroOrSpace($macros[$block]). $value;
    }
}


function newMacroOrSpace($block) {
    return (strlen($block) < 1) ? "/ab " : " ";
}

echo '<pre>';
var_dump($macros);
echo '</pre>';
exit();