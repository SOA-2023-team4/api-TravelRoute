function addInput(element) {
  let blank = document.querySelector("#blank-row");
  let parent = blank.parentElement;

  if (element.parentElement.previousElementSibling.lastChild.value.trim() === "") {
    return false;
  }

  // create div element
  let div = document.createElement("div");
  div.setAttribute("class", "row vertical-align query-bar");

  // create heading field
  let heading_div = document.createElement("div");
  heading_div.setAttribute("class", "col-md-2 col-sm-3");

  let headingText = document.createTextNode("To");

  let heading = document.createElement("div");
  heading.setAttribute("class", "text-right");

  heading.appendChild(headingText);
  heading_div.appendChild(heading);

  // crete input field
  let input = document.createElement("input");
  input.setAttribute("type", "text");
  input.setAttribute("name", "places[]");
  input.setAttribute("id", "destination");
  input.setAttribute("class", "form-control");
  input.setAttribute("placeholder", "e.g. Taipei 101");

  let input_div = document.createElement("div");
  input_div.setAttribute("class", "col-md-8 col-sm-5");
  input_div.appendChild(input);


  // create add button
  let add = document.createElement("span");
  add.setAttribute("class", "btn btn-success btn-small")
  add.setAttribute("onclick", "addInput(this)")
  let addText = document.createTextNode("+");
  add.appendChild(addText);

  // create remove button
  let remove = document.createElement("span");
  remove.setAttribute("class", "btn btn-danger btn-small")
  remove.setAttribute("onclick", "removeInput(this)")
  remove.style.display = "none";
  let removeText = document.createTextNode("-");
  remove.appendChild(removeText);

  // create utility div
  let util_div = document.createElement("div");
  util_div.setAttribute("class", "col-md-1 col-sm-2");
  util_div.appendChild(add);
  util_div.appendChild(remove);

  // append elements to div
  parent.insertBefore(div, blank);
  div.appendChild(heading_div);
  div.appendChild(input_div);
  div.appendChild(util_div)

  element.nextElementSibling.style.display = "block";
  element.style.display = "none";
}

function removeInput(element) {
  element.parentElement.parentElement.remove();
}