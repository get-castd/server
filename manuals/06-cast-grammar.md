# CAST — Formal Grammar

**Version:** 1.0
**Status:** Active
**Notation:** Extended Backus-Naur Form (ISO/IEC 14977)

---

## Overview

CAST (Content & Structure Templating) uses five delimiter pairs, each
with a distinct second character. A template is a sequence of plain text
and CAST blocks. The parser scans left-to-right, character by character,
with single-character lookahead.

---

## Document Structure

```ebnf
template        = { text | block } ;

block           = data_block
                | logic_block
                | preset_block
                | persistence_block
                | comment_block ;

text            = (* any character sequence not starting a block *) ;
```

---

## Delimiter Detection

```ebnf
data_block          = "{{" , ws , data_content , ws , "}}" ;
logic_block         = "{!" , ws , logic_content , ws , "!}" ;
preset_block        = "{(" , ws , preset_content , ws , ")}" ;
persistence_block   = "{*" , ws , persistence_content , ws , "*}" ;
comment_block       = "{#" , comment_text , "#}" ;

ws                  = { whitespace } ;
whitespace          = " " | "\t" | "\n" | "\r" ;
```

---

## 1. Data: `{{ }}`

```ebnf
data_content    = assignment
                | dump
                | variable_output ;

(* Assignment: {{ name = value }} or {{ name = value | modifier }} *)
assignment      = identifier , ws , "=" , ws , value_expr ,
                  [ ws , modifier_chain ] ;

(* Debug dump: {{ dump name }} *)
dump            = "dump" , ws , identifier ;

(* Variable output: {{ name }} or {{ name | modifier1 | modifier2 }} *)
variable_output = accessor , [ ws , modifier_chain ] ;

(* Value expressions in assignments *)
value_expr      = string_literal
                | number_literal
                | boolean_literal
                | accessor ;

(* Property and array access *)
accessor        = identifier , { "." , identifier | "[" , index , "]" } ;
index           = number_literal | identifier ;
```

---

## 2. Logic: `{! !}`

```ebnf
logic_content   = if_start
                | elseif_stmt
                | else_stmt
                | endif
                | each_start
                | endeach
                | bind_start
                | endbind
                | api_start
                | endapi
                | extends ;

(* Conditionals *)
if_start        = "if" , ws , condition ;
elseif_stmt     = "elseif" , ws , condition ;
else_stmt       = "else" ;
endif           = "endif" ;

condition       = accessor , [ ws , comparator , ws , value_expr ] ;
comparator      = "==" | "!=" | ">" | "<" | ">=" | "<=" ;

(* Iteration — implicit item and index variables *)
each_start      = "each" , ws , accessor ;
endeach         = "endeach" ;

(* Reactive binding *)
bind_start      = "bind" , ws , variable_list ;
endbind         = "endbind" ;

variable_list   = accessor , { ws , "," , ws , accessor } ;

(* API connections *)
api_start       = "api" , ws , ( api_path | api_call ) ,
                  [ ws , modifier_chain ] ;
endapi          = "endapi" ;

api_path        = string_literal ;
api_call        = identifier , "(" , [ param_list ] , ")" ;
param_list      = identifier , { ws , "," , ws , identifier } ;

(* Template inheritance *)
extends         = "extends" , ws , string_literal ,
                  [ ws , "|" , ws , "slotlist" ] ;
```

---

## 3. Presets: `{( )}`

```ebnf
preset_content  = slot_end
                | preset_def_end
                | slot_start
                | preset_def_start
                | extension_call
                | preset_call ;

(* Slot system *)
slot_start      = "slot" , ws , identifier ;
slot_end        = "endslot" ;

(* Inline preset macros — template-local reusable blocks *)
preset_def_start = "preset" , ws , identifier ,
                   [ "[" , param_names , "]" ] ;
preset_def_end  = "endpreset" ;

param_names     = identifier , { ws , "," , ws , identifier } ;

(* Extension calls: {( cnx:name[arg1, arg2] )} *)
extension_call  = "cnx:" , identifier ,
                  [ "[" , ext_arg_list , "]" ] ;

ext_arg_list    = ext_arg , { ws , "," , ws , ext_arg } ;
ext_arg         = string_literal | number_literal | boolean_literal
                | accessor ;

(* Preset call — two prefix forms *)
preset_call     = preset_name ,
                  [ "[" , arg_list , "]" | ws , attributes ] ,
                  [ ws , modifier_chain ] ;

preset_name     = canonical_name | legacy_name | bare_name ;
canonical_name  = "cn:preset." , dotted_name ;
legacy_name     = "cm." , dotted_name ;
bare_name       = identifier , { "-" , identifier } ;

dotted_name     = identifier , { "." , identifier } ;
```

---

## 4. Persistence: `{* *}`

```ebnf
persistence_content = read_start
                    | read_end
                    | write_start
                    | write_end
                    | update_start
                    | update_end
                    | delete_stmt
                    | backup
                    | require_start
                    | require_end
                    | auth_stmt
                    | auth_end
                    | volume_def ;

(* CRUD operations *)
read_start      = "read" , ws , target , [ ws , modifier_chain ] ;
read_end        = "endread" ;

write_start     = "write" , ws , target ;
write_end       = "endwrite" ;

update_start    = "update" , ws , target , [ ws , modifier_chain ] ;
update_end      = "endupdate" ;

delete_stmt     = "delete" , ws , target , [ ws , modifier_chain ] ;

(* Target: db.tablename or volume.volumename *)
target          = identifier , "." , identifier ;

(* Database backup *)
backup          = "backup" , ws , "db" ;

(* Permission checks *)
require_start   = "require" , ws , require_condition ;
require_end     = "endrequire" ;

require_condition = "logged-in"
                  | attribute ;

(* Authentication *)
auth_stmt       = "auth" , ws , auth_action ,
                  [ ws , modifier_chain ] ;
auth_end        = "endauth" ;

auth_action     = "login" | "logout" | "register" ;

(* Volume definition *)
volume_def      = "volume" , ws , string_literal ,
                  [ ws , modifier_chain ] ;
```

---

## 5. Comments: `{# #}`

```ebnf
comment_text    = (* any character sequence not containing "#}" *) ;
```

Comments are stripped from output. They may span multiple lines.

---

## Shared Productions

```ebnf
(* Modifier pipeline: | modifier1 | modifier2 *)
modifier_chain  = "|" , ws , modifier_group ,
                  { ws , "|" , ws , modifier_group } ;

modifier_group  = modifier , { ws , "&" , ws , modifier } ;

modifier        = identifier , [ "=" , modifier_value ] ;
modifier_value  = string_literal | number_literal | identifier ;

(* Arguments in bracket syntax *)
arg_list        = argument , { ws , "," , ws , argument } ;
argument        = attribute | positional_arg ;

attribute       = identifier , "=" , attr_value ;
attr_value      = string_literal | number_literal | boolean_literal
                | accessor ;

positional_arg  = string_literal | number_literal | boolean_literal
                | accessor ;

(* Attributes in space-separated syntax *)
attributes      = attribute_item , { ws , attribute_item } ;
attribute_item  = identifier , [ "=" , attr_value ] ;

(* Attribute list for presets with bracket syntax *)
attr_list       = attribute , { ws , "," , ws , attribute } ;

(* Identifiers and literals *)
identifier      = letter , { letter | digit | "_" | "-" } ;
dotted_ident    = identifier , { "." , identifier } ;

string_literal  = '"' , { string_char } , '"'
                | "'" , { string_char_sq } , "'" ;
string_char     = (* any character except '"' *) ;
string_char_sq  = (* any character except "'" *) ;

number_literal  = [ "-" ] , digit , { digit } , [ "." , digit , { digit } ] ;
boolean_literal = "true" | "false" ;

letter          = "a" | "b" | ... | "z" | "A" | "B" | ... | "Z" ;
digit           = "0" | "1" | ... | "9" ;
```

---

## Delimiter Summary

| Opening | Closing | Second Char | Domain        |
|---------|---------|-------------|---------------|
| `{{`    | `}}`    | `{`         | Data          |
| `{!`    | `!}`    | `!`         | Logic         |
| `{(`    | `)}`    | `(`         | Presets       |
| `{*`    | `*}`    | `*`         | Persistence   |
| `{#`    | `#}`    | `#`         | Comments      |

The scanner detects `{` followed by one of `{ ! ( * #`. Any `{` not
followed by one of these five characters is treated as plain text.

---

## Implicit Variables

| Variable   | Available in        | Value                     |
|------------|---------------------|---------------------------|
| `item`     | `{! each !}` body   | Current element           |
| `index`    | `{! each !}` body   | 0-based iteration counter |
| `user`     | Always              | Current user or null      |
| `form`     | POST requests       | Form field values         |
| `route`    | Always              | URL parameters            |
| `now`      | Always              | Current timestamp         |
| `redirect` | Assignment target   | Triggers HTTP redirect    |

---

## System Constants

```ebnf
system_constant = "cn:" , constant_namespace , "." , identifier ;

constant_namespace = "path"     (* Asset paths: styles, scripts, images *)
                   | "list"     (* Enumerable lists: workspaces, themes *)
                   | "meta" ;   (* Server metadata: version, port *)
```

---

## Precedence and Nesting

1. Blocks are parsed left-to-right, no operator precedence within a block
2. Modifier chains are applied left-to-right (pipe order)
3. `{! each !}` creates a new scope — `item` and `index` shadow outer variables
4. `{! extends !}` must be the first meaningful token in a template
5. Blocks may contain other blocks (e.g. `{! if !}` inside `{* read *}`)
6. Comments are stripped before any other processing

---

*Copyright 2025 Vivian Voss. Apache-2.0*
