$(document).ready(function() {

    /* Helper function to return all the data- attributes from the element
     * and returns a hash of all elements
     */
    parse_data_attrs = function(elem) {
        var hash = new Object();
        var attr_array = elem.attributes;
        
        // filter all attributes that start with "data-" and create
        // 
        $.each($.grep(attr_array, function(attr, i) {
                          return attr.name.match(/^data-/);
                      }), 
               function() {
                   hash[this.name.replace(/^data-/, "")] = this.value;
               });

        return hash;
    }

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
    $("a[rel*=rest_get]").click(
        function() {
            var data = parse_data_attrs(this);

            $(data.target).html("Loading...");

            $.get(data.action, function(response_html) { 
                      $(data.target).html(response_html);
                  });
        });

});
