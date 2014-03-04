;;; Compiled snippets and support files for `c-mode'
;;; Snippet definitions:
;;;
(yas-define-snippets 'c-mode
                     '(("cmain" "#include <stdio.h>\n\nint main(int argc, char *argv[]) {\n\n    return 0;\n}\n\n" "c-main" nil nil nil nil nil nil)
                       ("oaheader" "\n/******************* ONEACCESS ****************************\n * \\file    `(file-name-nondirectory (buffer-file-name))`\n * \\brief   ${brief}\n *\n * \\author  ${author}\n *\n * \\warning ${warning}\n *\n * \\todo    ${todo}\n *\n * \\note ${note}\n ***********************************************************/\n\n#ifndef ${1:_`(upcase (file-name-nondirectory (file-name-sans-extension (buffer-file-name))))`_H_}\n#define $1\n\n$0\n\n#endif /* $1 */\n" "oa header file" nil nil nil nil nil nil)
                       ("oamcapisrc" "/******************* ONEACCESS ******************************\n * \\file    `(file-name-nondirectory (buffer-file-name))`\n * \\brief   ${brief}\n *\n * \\author  ${author}\n *\n * \\warning ${warning}\n *\n * \\todo    ${todo}\n *\n * \\note ${note}\n ***********************************************************/\n\n#include <oamcapi.h>\n\nvoid `(file-name-nondirectory (file-name-sans-extension(buffer-file-name)))`($0)\n{\n   $1\n}\n" "oamcapisrc" nil nil nil nil nil nil)
                       ("oasrc" "/******************* ONEACCESS ******************************\n * \\file    `(file-name-nondirectory (buffer-file-name))`\n * \\brief   ${brief}\n *\n * \\author  ${author}\n *\n * \\warning ${warning}\n *\n * \\todo    ${todo}\n *\n * \\note ${note}\n ***********************************************************/\n\n$0" "oa source file" nil nil nil nil nil nil)
                       ("oatc" "\n/**\n * \\fn $1\n * \\prq_id PRQ-$2\n * \\prq $3\n * \\test_id TC-$2\n * \\test_case_title ${4:Title}\n * \\test $5\n */\nTEST_CASE()\nvoid test_${4:$(mapconcat 'capitalize (split-string text \" \") \"\")}()\n{\n   TEST_IGNORE();\n   $0\n}\n" "oa test case" nil nil nil nil nil nil)
                       ("oaunit" "/** **************** ONEACCESS ****************************\n * \\file    `(file-name-nondirectory (buffer-file-name))`\n * \\brief   ${brief}\n *\n * \\author  ${author}\n *\n * \\warning ${warning}\n *\n * \\todo    ${todo}\n *\n * \\note ${note}\n ***********************************************************/\n\n#include \"unity.h\"\n\n#define TEST_CASE(...)\n\nvoid setUp(void)\n{\n   //This is run before EACH TEST\n}\n\nvoid tearDown(void)\n{\n   //This is run after EACH TEST\n}\n" "oa test unit file" nil nil nil nil nil nil)
                       ("oatrc" "TRACE(\"$0\");" "oatrace" nil nil nil nil nil nil)))


;;; Do not edit! File generated at Tue Mar  4 13:58:41 2014
