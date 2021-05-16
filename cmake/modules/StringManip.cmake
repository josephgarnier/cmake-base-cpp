# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#[=======================================================================[.rst:

StringManip
-----------
Operations on strings. It requires CMake 3.16 or newer.

Synopsis
^^^^^^^^
.. parsed-literal::

    string_manip(`SPLIT`_ <string> <output_list_var>)
    string_manip(`TRANSFORM`_ <string_list_var> START_CASE [OUTPUT_VARIABLE <output_list_var>])
    string_manip(`TRANSFORM`_ <string_var> START_CASE [OUTPUT_VARIABLE <output_var>])
    string_manip(`STRIP_INTERFACES`_ <string_var> [OUTPUT_VARIABLE <output_var>])

Usage
^^^^^

.. _SPLIT:
.. code-block:: cmake

  string_manip(SPLIT <string> <output_list_var>)

Split the string ``<string>`` into a list of strings wherever non-alphanumeric
character (in using the CMake string(MAKE_C_IDENTIFIER) function) or a uppercase
character is detected. This list is returned in ``<output_list_var>`` as a list.
In case where no special char is found, the input string is returned as a list.

.. _TRANSFORM:
.. code-block:: cmake

  string_manip(TRANSFORM <string_list_var> START_CASE [OUTPUT_VARIABLE <output_list_var>])

Transform each element of the list of strings ``<string_list_var>`` into start
case, storing the result in-place or in the specified ``<output_list_var>`` as a list.

.. code-block:: cmake

  string_manip(TRANSFORM <string_var> START_CASE [OUTPUT_VARIABLE <output_var>])

Split and transform the string ``<string_var>`` into start case then store de result in
place or in the specified ``<output_var>`` as a string.

.. code-block:: cmake

  string_manip(STRIP_INTERFACES <string_var> [OUTPUT_VARIABLE <output_var>])

Strip BUILD_INTERFACE and INSTALL_INTERFACE generator expressions from the input
<string_var> and store the result in place or in the specified <output_var>.

#]=======================================================================]
include_guard()

cmake_minimum_required (VERSION 3.16)

#------------------------------------------------------------------------------
# Public function of this module.
function(string_manip)
	set(options START_CASE)
	set(one_value_args TRANSFORM STRIP_INTERFACES OUTPUT_VARIABLE)
	set(multi_value_args SPLIT)
	cmake_parse_arguments(SM "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
	
	if(DEFINED SM_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${SM_UNPARSED_ARGUMENTS}\"")
	endif()

	if(DEFINED SM_SPLIT)
		_string_manip_split()
	elseif(DEFINED SM_TRANSFORM)
		list(LENGTH ${SM_TRANSFORM} nb_args)
		if(${nb_args} EQUAL 1)
			_string_manip_transform_string_var()
		else()
			_string_manip_transform_string_list()
		endif()
	elseif(DEFINED SM_STRIP_INTERFACES)
		_string_manip_strip_interfaces()
	else()
		message(FATAL_ERROR "Operation argument is missing")
	endif()
endfunction()

#------------------------------------------------------------------------------
# Internal usage.
macro(_string_manip_split)
	if(DEFINED SM_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${SM_UNPARSED_ARGUMENTS}\"")
	endif()
	list(LENGTH SM_SPLIT nb_args)
	if(NOT ${nb_args} EQUAL 2)
		message(FATAL_ERROR "SPLIT argument is missing or wrong")
	endif()

	list(GET SM_SPLIT 0 string_to_split)
	string(MAKE_C_IDENTIFIER "${string_to_split}" string_to_split)
	string(REGEX MATCHALL "[^_][^|A-Z|_]*" string_list "${string_to_split}")
	list(GET SM_SPLIT 1 output_list_var)
	set(${output_list_var} "${string_list}" PARENT_SCOPE)
endmacro()

#------------------------------------------------------------------------------
# Internal usage.
macro(_string_manip_transform_string_list)
	if(DEFINED SM_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${SM_UNPARSED_ARGUMENTS}\"")
	endif()
	if(NOT DEFINED SM_TRANSFORM)
		message(FATAL_ERROR "TRANSFORM argument is missing")
	endif()
	if(NOT ${SM_START_CASE})
		message(FATAL_ERROR "START_CASE argument is missing")
	endif()

	set(formated_word_list "")
	foreach(word IN ITEMS ${${SM_TRANSFORM}})
		string_manip(TRANSFORM word START_CASE OUTPUT_VARIABLE formated_word)
		list(APPEND formated_word_list "${formated_word}")
	endforeach()
	
	if(NOT DEFINED SM_OUTPUT_VARIABLE)
		set(${SM_TRANSFORM} "${formated_word_list}" PARENT_SCOPE)
	else()
		set(${SM_OUTPUT_VARIABLE} "${formated_word_list}" PARENT_SCOPE)
	endif()
endmacro()

#------------------------------------------------------------------------------
# Internal usage.
macro(_string_manip_transform_string_var)
	if(DEFINED SM_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${SM_UNPARSED_ARGUMENTS}\"")
	endif()
	if(NOT DEFINED SM_TRANSFORM)
		message(FATAL_ERROR "TRANSFORM arguments is missing")
	endif()
	if(NOT ${SM_START_CASE})
		message(FATAL_ERROR "START_CASE argument is missing")
	endif()
	
	set(word_list "")
	set(formated_word "")
	string_manip(SPLIT "${${SM_TRANSFORM}}" word_list)
	list(LENGTH word_list nb_args)
	if(${nb_args} GREATER_EQUAL 2)
		# The split function returned a list of words
		string_manip(TRANSFORM word_list START_CASE)
		list(JOIN word_list "" formated_word)
	else()
		# The split function returned a single word
		string(TOLOWER "${word_list}" formated_word)
		string(SUBSTRING ${formated_word} 0 1 first_letter)
		string(TOUPPER "${first_letter}" first_letter)
		string(REGEX REPLACE "^.(.*)" "${first_letter}\\1" formated_word "${formated_word}")
	endif()

	if(NOT DEFINED SM_OUTPUT_VARIABLE)
		set(${SM_TRANSFORM} "${formated_word}" PARENT_SCOPE)
	else()
		set(${SM_OUTPUT_VARIABLE} "${formated_word}" PARENT_SCOPE)
	endif()
endmacro()

#------------------------------------------------------------------------------
# Internal usage.
macro(_string_manip_strip_interfaces)
	if(DEFINED SM_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${SM_UNPARSED_ARGUMENTS}\"")
	endif()
	if(NOT DEFINED SM_STRIP_INTERFACES)
		message(FATAL_ERROR "STRIP_INTERFACES argument is missing")
	endif()

	set(regex ";?\\$<BUILD_INTERFACE:[^>]+>|;?\\$<INSTALL_INTERFACE:[^>]+>")
	string(REGEX REPLACE "${regex}" "" string_striped "${${SM_STRIP_INTERFACES}}")

	if(NOT DEFINED SM_OUTPUT_VARIABLE)
		set(${SM_STRIP_INTERFACES} "${string_striped}" PARENT_SCOPE)
	else()
		set(${SM_OUTPUT_VARIABLE} "${string_striped}" PARENT_SCOPE)
	endif()
endmacro()