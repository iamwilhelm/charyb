$(document).ready(function() {

    /* Makes an GET ajax link and posts the result from server in the target 
     * DOM element
     * 
     * It has a couple parameters it uses:
     * 
     *   * data-href - The URL where to make the AJAX request
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
    $("a.get").click(function() {
        url = $(this).attr("data-href");
        target = $(this).attr("data-target");
        $.get(url, function(data) { 
            $(target).html(data);
        });
    });

});
