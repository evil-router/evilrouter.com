---
title: "Hugo Shortcodes for embedding code"
date: 2024-05-15T20:48:32-04:00
draft: False
Author: "Bernard McCormack"
slug: "hugo-shortcodes-embedding-code"
tags:
- "hugo"
- "shortcodes"
- "go-template"
---

## Creating a Hugo Shortcode for Embedding Code

Hugo shortcodes are simple snippets of code that can be used to render content in a Hugo site. They are a great way to add functionality to your site without having to write a lot of custom code.
In this post, we will create a Hugo shortcode that allows you to embed code snippets in your content.

### Step 1: Create a New Shortcode File
Create a new file in the `layouts/shortcodes` directory of your Hugo site. Name the file `code.html`.

Here we are going to create a shortcode that takes three parameters: `file`, `format`, and `project`. 
This allows us to test the shortcode works and where to place it. 

```go-html-template
{{- $file := .Get "file"}}
{{- $format := .Get "format" | default "bash" }}
{{  $project := .Get "project" | default .Page.Slug }}
{{  printf "file - %s, format - %s, project - %s " $file $format $project }}
```
This gets the named parameter file with no default, format with a default of `bash` and project with a default of the page slug.

This will for the shortcode to be used in the content as follows:

```go-html-template
{{</* code file="main.tf" format="hcl" project="workload-federation-aws-tfc" */>}}
```

Output:
    - {{< code-pt1  file="main.tf" format="hcl" project="workload-federation-aws-tfc" >}}

### Step 2: Add the Code to the Shortcode File

Here we are going to have to read the file specified in the `file` parameter and render it with syntax highlighting using the `format` parameter.
to do this we will use the [highlight](https://gohugo.io/functions/transform/highlight/) and [readFile](https://gohugo.io/functions/os/readfile/)  provided by Hugo. 
We will use the path from the file,

Then we can replace the code in the shortcode file with the following code:

{{< code file="code.html" format="go-html-template" >}}

and then we can use the shortcode in the content as follows:

```go-html-template
{{</* code file="code.html" format="go-html-template" */>}}
``` 
to render the code.html in the static/code/hugo-shortcodes-embedding-code directory.


### Congratulations! You have created a Hugo shortcode for embedding code snippets in your content.



