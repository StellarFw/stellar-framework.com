---
title: Validation
type: guide
order: 17
---

## Introduction

Stelar provides a powerful system to validate your application's incoming data. You can specify rules in the inputs of your actions or use the validation system directly, given the data to be validated and a set of rules.

## Validation Quickstart

To learn about Stellar's powerful validation features, let's look at a complete example of validating an action request and displaying the error messages.

To use the validation system directly in your actions' declarations to automatically validate the requests you just need specify the rules on your inputs. On the follow example there is an action to register an user, this action receives an email and a password who needs to be confirmed.

```javascript
exports.registerUser = {
  name: 'registerUser',
  description: 'This action registers a new user.'

  inputs: {
    email: {
      validator: 'required|email'
    },
    password: {
      validator: 'required|confirmed'
    }
  },

  run (api, action, next) {
    // logic to register the user...

    next()
  }
}
```

To set the validation rules for a input field you must set the `validator` property with the desired rules.

## Available Validation Rules

Below is a list of all available validation rules and their function:

<a name="rule-alpha"></a>
### alpha

The field under validation must be entirely alphabetic characters.

<a name="rule-alpha-dash"></a>
### alpha_dash

The fields under validation may have alpha-numeric characters, as well as dashes and underscores.

<a name="rule-alpha-num"></a>
### alpha_num

The field under validation must be entirely alpha-numeric characters.

<a name="rule-array"></a>
### array

The field under validation must be an `array`.

<a name="rule-before"></a>
### before:_date_

The field under validation must be a value preceding the given date.

<a name="rule-between"></a>
### between:_min_,_max_

The field under validation must have a size between the given _min_ and _max_. Strings, numerics, and arrays are evaluated in the same fashion as the [`size`](#rule-size) rule.

<a name="rule-boolean"></a>
### boolean

The field under validation must be able to cast as a boolean. Accepted input are `true` and `false`.

<a name="rule-confirmed"></a>
### confirmed

The field under validation must have a matching field of `foo_confirmation`. For example, if the field under validation is `password`, a matching `password_confirmation` field must be present in the input.

<a name="rule-date"></a>
### date

The field under validation must be a valid date according to the `Date` JavaScript function.

<a name="rule-different"></a>
### different:_field_

The field under validation must have a different value than _field_.

<a name="rule-email"></a>
### email

The field under validation must be formatted as an e-mail address.

<a name="rule-filled"></a>
### filled

The field under validation must not be empty when it is present.

<a name="rule-in"></a>
### in:_foo_,_bar_,...

The field under validation must be included in the given list of values.

<a name="rule-ip"></a>
### ip

The field under validation must be an IP address.

<a name="rule-json"></a>
### json

The field under validation must be a valid JSON string.

<a name="rule-max"></a>
### max

The field under validation must be less than or equal to a maximum _value_. Strings, numerics, and arrays are evaluated in the same fashion as the [`size`](#rule-size) rule.

<a name="rule-min"></a>
### min

The field under validation must have a minimum _value_. Strings, numerics, and arrays are evaluated in the same fashion as the [`size`](#rule-size) rule.

<a name="rule-not-in"></a>
### not_in:_foo_,_bar_,...

The field under validation must not be included in the given list of values.

<a name="rule-regex"></a>
### regex:_pattern_,_flags_

The field under validation must match the given regular expression.

> **Note:** When using the `regex` pattern, it may be necessary to specify rules in an array instead of using pipe delimiters, especially if the regular expression contains a pipe character.

<a name="rule-required"></a>
### required

The field under validation must be present in the input data.

<a name="rule-required-if"></a>
### required_if:_anotherfield_,_value_,...

The fields under validation must be present and not empty if the _anotherfield_ field is equal to any _value_.

<a name="rule-required-unless"></a>
### required_unless:_anotherfield_,_value_,...

The field under validation must be present and not empty unless the _anotherfield_ field is equal to any _value_.

<a name="rule-required-with"></a>
### required_with:_foo_,_bar_,...

the field under validation must be present and not empty **only if** any of the other specified field are present.

<a name="rule-required-with-all"></a>
### required_with_all:_foo_,_bar_,...

The field under validation must be present and not empty **only if** all of the other specified fields are present.

<a name="rule-required-without"></a>
### required_without:_foo_,_bar_,...

The field under validation must be present and not empty **only when** any of the other specified fields are not present.

<a name="rule-required-without-all"></a>
### required_without_all:_foo_,_bar_,...

The field under validation must be present and not empty **only when** all of the other specified fields are not present.

<a name="rule-same"></a>
### same:_field_

The given _field_ must match the field under validation.

<a name="rule-size"></a>
### size:_value_

The field under validation must have a size matching the given _value_. For string data, _value_ corresponds to the number of characters. For numeric data, _value_ corresponds to a given integer value. For an array, _size_ corresponds to the `length` of the array.

<a name="rule-url"></a>
### url

The field under validation must be a valid URL.

## Using Functions as a Validator

You can also use functions to validate your input. Please, don't use arrow functions otherwise Stellar will not be able to inject the `api` instance as the context (`this`). The function receives one parameter, who is the inputted value.

```javascript
exports.example = {
  name: 'example',

  inputs: {
    value: {
      validator: function (value) {
        return (value === 'test123') ? true : 'This is an error message!'
      }
    }
  }
}
```

The function must return an `Boolean` or a `String`, where `String` or `false` means that the validation failed. If a `String` is returned this will be used as the error message.

## Automatic Error Response

Stellar can generate automatic error responses when at least one input field don't match with the validation rules defined in the action. The error message is always a hash here the key is the field name and the value is the effective error for that field. The follow snippet shows an error response:

```json
{
  "error": {
    "email": "The email must be a valid email address.",
    "password": "The password field is required."
  }
}
```
