" Vim syntax file
" For Vim 7.x
" Language:	rs274ngc
" Maintainer:	Michael Buesch <mb@bu3sch.de>
" Last Change:	2008 Sept

if exists("b:current_syntax")
	finish
endif

syn case ignore

syn match rs274ngcComment		/(.*)/
syn match rs274ngcO			/O[0-9]\+/
syn match rs274ngcG			/G[0-9\.]\+/
syn match rs274ngcL			/L/
syn match rs274ngcP			/P/
syn match rs274ngcM			/M[0-9]\+/
syn match rs274ngcX			/X/
syn match rs274ngcY			/Y/
syn match rs274ngcZ			/Z/
syn match rs274ngcU			/U/
syn match rs274ngcV			/V/
syn match rs274ngcW			/W/
syn match rs274ngcA			/A/
syn match rs274ngcB			/B/
syn match rs274ngcC			/C/
syn match rs274ngcS			/S/
syn match rs274ngcF			/F/
syn match rs274ngcD			/D/
syn match rs274ngcIf			/if/
syn match rs274ngcEndif			/endif/
syn match rs274ngcParam			/#[0-9]\+/
syn match rs274ngcNamedParam		/#<[a-z_][a-z0-9_]*>/
syn match rs274ngcOperEq		/eq/
syn match rs274ngcOperNe		/ne/
syn match rs274ngcOperGt		/gt/
syn match rs274ngcOperGe		/ge/
syn match rs274ngcOperLt		/lt/
syn match rs274ngcOperLe		/le/
syn match rs274ngcAssign		/=/
syn match rs274ngcPlus			/+/
syn match rs274ngcMinus			/-/
syn match rs274ngcTimes			/\*/
syn match rs274ngcDiv			/\//
syn match rs274ngcPow			/\*\*/
syn match rs274ngcMod			/mod/
syn match rs274ngcAnd			/and/
syn match rs274ngcOr			/or/
syn match rs274ngcXor			/xor/
syn match rs274ngcNumber		/-\=[0-9]*\.\=[0-9]\+/
syn match rs274ngcFuncAtan		/atan/
syn match rs274ngcFuncAbs		/abs/
syn match rs274ngcFuncAcos		/acos/
syn match rs274ngcFuncAsin		/asin/
syn match rs274ngcFuncCos		/cos/
syn match rs274ngcFuncExp		/exp/
syn match rs274ngcFuncFix		/fix/
syn match rs274ngcFuncFup		/fup/
syn match rs274ngcFuncRound		/round/
syn match rs274ngcFuncLn		/ln/
syn match rs274ngcFuncSin		/sin/
syn match rs274ngcFuncSqrt		/sqrt/
syn match rs274ngcFuncTan		/tan/
syn match rs274ngcDo			/do/
syn match rs274ngcWhile			/while/
syn match rs274ngcEndwhile		/endwhile/
syn match rs274ngcSub			/sub/
syn match rs274ngcEndsub		/endsub/
syn match rs274ngcCall			/call/
syn match rs274ngcBreak			/break/
syn match rs274ngcReturn		/return/
syn match rs274ngcPercent		/%/

syn case match

hi def link rs274ngcComment		Comment
hi def link rs274ngcO			Label
hi def link rs274ngcG			Keyword
hi def link rs274ngcL			Keyword
hi def link rs274ngcP			Keyword
hi def link rs274ngcM			Keyword
hi def link rs274ngcX			Keyword
hi def link rs274ngcY			Keyword
hi def link rs274ngcZ			Keyword
hi def link rs274ngcU			Keyword
hi def link rs274ngcV			Keyword
hi def link rs274ngcW			Keyword
hi def link rs274ngcA			Keyword
hi def link rs274ngcB			Keyword
hi def link rs274ngcC			Keyword
hi def link rs274ngcS			Keyword
hi def link rs274ngcF			Keyword
hi def link rs274ngcD			Keyword
hi def link rs274ngcIf			Conditional
hi def link rs274ngcEndif		Conditional
hi def link rs274ngcParam		Identifier
hi def link rs274ngcNamedParam		Identifier
hi def link rs274ngcOperEq		Operator
hi def link rs274ngcOperNe		Operator
hi def link rs274ngcOperGt		Operator
hi def link rs274ngcOperGe		Operator
hi def link rs274ngcOperLt		Operator
hi def link rs274ngcOperLe		Operator
hi def link rs274ngcAssign		Operator
hi def link rs274ngcPlus		Operator
hi def link rs274ngcMinus		Operator
hi def link rs274ngcTimes		Operator
hi def link rs274ngcDiv			Operator
hi def link rs274ngcPow			Operator
hi def link rs274ngcMod			Operator
hi def link rs274ngcAnd			Operator
hi def link rs274ngcOr			Operator
hi def link rs274ngcXor			Operator
hi def link rs274ngcNumber		Number
hi def link rs274ngcFuncAtan		Function
hi def link rs274ngcFuncAbs		Function
hi def link rs274ngcFuncAcos		Function
hi def link rs274ngcFuncAsin		Function
hi def link rs274ngcFuncCos		Function
hi def link rs274ngcFuncExp		Function
hi def link rs274ngcFuncFix		Function
hi def link rs274ngcFuncFup		Function
hi def link rs274ngcFuncRound		Function
hi def link rs274ngcFuncLn		Function
hi def link rs274ngcFuncSin		Function
hi def link rs274ngcFuncSqrt		Function
hi def link rs274ngcFuncTan		Function
hi def link rs274ngcDo			Repeat
hi def link rs274ngcWhile		Repeat
hi def link rs274ngcEndwhile		Repeat
hi def link rs274ngcCall		Keyword
hi def link rs274ngcSub			Keyword
hi def link rs274ngcEndsub		Keyword
hi def link rs274ngcBreak		Keyword
hi def link rs274ngcReturn		Keyword
hi def link rs274ngcPercent		Todo

let b:current_syntax = "rs274ngc"
