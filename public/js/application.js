$(document).ready(function() {

    /* Helper function to return all the data- attributes from the element
     * and returns a hash of all elements
     */
    parse_data_attrs = function(elem) {
        var hash = new Object();
        
        // filter all attributes that start with "data-" and create
        // 
        $.each($.grep(elem.attributes, 
                      function(attr, i) {
                          return attr.name.match(/^data-/);
                      }), 
               function() {
                   hash[this.name.replace(/^data-/, "")] = this.value;
               });

        return hash;
    };

    /* Makes an GET ajax link and posts the result from server in the target 
     * DOM element
     * 
     * It has a couple parameters it uses:
     * 
     *   * data-action - The URL where to make the AJAX request
     *   * data-target - Which DOM element to insert the results of the request
     *        Use JQuery selectors to target the element
     *   * data-effect - The jquery effect to use to transition in the new 
     *        results.
     * 
     * Note that you need jquery-ui in order to use the effects.
     * 
     * Example:
     *   <a href="#" class="get"
     *               data-href="/posts/new"
     *               data-target="#post_new"
     *   </a>
     */
    $("a[rel*=rest_get]").live("click", 
        function(event) {
            var data = parse_data_attrs(event.target);

            $(data.target).html("Loading...");

            $.get(data.action, function(response_html) { 
                      $(data.target).html(response_html);
                  });
        });

    /* Makes all preview buttons in previewable forms trigger a custom event 
     * called preview on the form
     */
    $("form input.preview").live("click",
        function(event) {
            // trigger the preview event in the surrounding closest parent form
            var form_elem = $(event.target).closest("form").trigger("preview");
        });

    toggleColor = function(form_element, input_field_name, color) {
        var css_selector = $(form_element).find("input[name=" + input_field_name + "]").val();
        var last_css_selector = css_selector;
        var last_heading_color = $(last_css_selector).css("background-color");
        
        return function() {
            // uncolor previously selected
            $(last_css_selector).css("background-color", last_heading_color);
            
            // color those that are selected and queue uncoloring
            $(css_selector).css("background-color", color);
        };
    };

    $("form.previewable").live("preview", 
        function(event) {
            // TODO this function body here is application specific (refactor)
            toggleColor(event.target, "col[heading_selector]", "yellow")();
            toggleColor(event.target, "col[column_selector]", "orange")();
        });

});
