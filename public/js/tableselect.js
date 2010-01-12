// globals
var one, two, rows, cols, tbl, logicalTable;

/*
 * make all tables selectable (the mouseover highlight) and handlers of mouse clicks
 */
$(document).ready(function() {
    $("#remote_page table").addClass("selectable");
    $("#remote_page table").mousedown(click);
});

/*
 * set a field to the currently selected cells. color table, set values in textarea, set xpaths.
 * fieldName is col_labels, row_labels or data
 */
function setButton(fieldName) {
    if (one == null || two == null) {
	alert("Select region first");
	return;
    }

    $("th, td").removeClass(fieldName);
    var cells = $("th.selected, td.selected");
    cells.addClass(fieldName);
    cells.removeClass("selected");

    var value = buildHierarchies(fieldName, cells)
    if (fieldName == "data")
	$("#table_info textarea[name=data_content]").html(value.join("\n"));
    else
	$("#table_info textarea[name=imported_table[" + fieldName + "_content]]").html(value.join("\n"));

    $("#table_info input[name=imported_table[" + fieldName + "_one]]").val(getXPath(one));
    $("#table_info input[name=imported_table[" + fieldName + "_two]]").val(getXPath(two));
}

/*
 * column header hierarchies are made by flattening the header rows.
 * row header hierarchies are made by lining up each items indentation.
 */
function buildHierarchies(fieldName, cells) {
    if (fieldName == "col_labels") {
        var ret = [];
        var top = lookupLogicalCorners(cells[0]).top;
        var bottom = lookupLogicalCorners(cells[cells.length - 1]).bottom;
        var bottomCells = Functional.select(function(x) { return lookupLogicalCorners(x).bottom == bottom; }, cells);
        for (var ii = 0; ii < bottomCells.length; ii++) {
            var col = lookupLogicalCorners(bottomCells[ii]).left;
            var hCells = []
            for (var rr = top; rr <= bottom; rr++) {
                var cell = trim(cleanStr(lookupCell(logicalTable[rr][col]).textContent));
                if (hCells[hCells.length - 1] != cell)
                    hCells.push(cell);
            }
            ret[ii] = hCells.join("`")
        }
    }
    else if (fieldName == "row_labels") {
        var ret = [];
        var lastIndent = 0;
        var parent = null;
        var ancestors = [];
        for (var ii = 0; ii < cells.length; ii++) {
            var hh = cleanStr(cells[ii].textContent);
            var indent = hh.length - ltrim(hh).length;
            hh = trim(hh);
            if (indent > lastIndent && parent != null) {
                for (var pp = 0; pp < indent - lastIndent - 1; pp++)
                    ancestors.push(null);
                ancestors.push(parent);
            }
            else if (indent < lastIndent)
                for (var pp = 0; pp < lastIndent - indent; pp++)
                    ancestors.pop();
            lastIndent = indent;
            ancestors.push(hh);
            ret.push(Functional.select(function(x) { return x != null; }, ancestors).join("`"));
            ancestors.pop();
            parent = hh;
        }
    }
    else
        ret = Functional.map(function(x) { return trim(cleanStr(x.textContent)); }, cells);

    return ret;
}

/* 
 * color the three sections of the table using xpaths from the form
 */
function colorTable() {
    colorSection($("#table_info input[name=imported_table[col_labels_one]]").val(), 
		 $("#table_info input[name=imported_table[col_labels_two]]").val(), "col_labels", true);
    colorSection($("#table_info input[name=imported_table[row_labels_one]]").val(), 
		 $("#table_info input[name=imported_table[row_labels_two]]").val(), "row_labels", false);
    colorSection($("#table_info input[name=imported_table[data_one]]").val(), 
		 $("#table_info input[name=imported_table[data_two]]").val(), "data", false);
    
    var cells = $("th.data, td.data");
    var value = Functional.map(function(x) { return trim(x.innerHTML); }, cells);
    $("#table_info textarea[name=data_content]").html(value.join("\n"));
}

/*
 * color a single section given its bounding xpaths
 */
function colorSection(xPathOne, xPathTwo, fieldName, findTbl) {
    var remote = $("#remote_page").get(0);

    one = document.evaluate(xPathOne, remote, null, XPathResult.ANY_TYPE, null).iterateNext();
    two = document.evaluate(xPathTwo, remote, null, XPathResult.ANY_TYPE, null).iterateNext();

    if (findTbl) {
	tbl = one.parentNode.parentNode.parentNode;
	computeLogicalTable();
    }
    
    if (one==null || two==null || tbl==null)
	return;

    update(fieldName);
}

/*
 * clear current selection from all tables
 */
function clear(event) {
    one = undefined;
    two = undefined;

    $("th, td").removeClass("selected");
}

/*
 * handle a mouse click on a table cell.  highlight selected cell(s)
 */
function click(event) {
    if (!event.target)
	return;

    if (!event.shiftKey) {
	tbl = event.target.parentNode.parentNode.parentNode;

        // clean up table.  remove links and internal tables.
        $("table", tbl).remove();
        $("td div", tbl).each(function(td){ $(this).replaceWith($(this).text());});

	computeLogicalTable();
	clear(event);
	one = event.target;
	$(one).addClass("selected");
    } else {
	if (one == null)
	    return;
        
	two = event.target;
	$(two).addClass("selected");
        
	update("selected");
    };
    return false;
}

/*
 * mark the highlighted cells with the given class.  handle rowspans and colspans correctly.
 */
function update(className) {
    var r1, r2, c1, c2; // logical row and col

    var boxOne = lookupLogicalCorners(one);
    var boxTwo = lookupLogicalCorners(two);
    var selectedBox = combineBoxes(boxOne, boxTwo);

    //alert(selectedBox.top + " " + selectedBox.left + " " + selectedBox.bottom + " "+ selectedBox.right);
    $("th, td", tbl).each(function() {
	if (boxIntersects(lookupLogicalCorners(this), selectedBox))
	    $(this).addClass(className);
	else
	    $(this).removeClass(className);
    });
}

/*
 * lookup cell in actual table given its row and col from logical table.
 * pos is two element array: [row, col]
 */
function lookupCell(pos) {
    return tbl.rows[pos[0]].cells[pos[1]];
}

/*
 * handle colspans and rowspans
 */
function lookupLogicalCorners(cell) {
    var top = cell.parentNode.rowIndex;
    var left = cell.cellIndex;
    while (logicalTable[top].length > left
	   && (logicalTable[top][left][0] != cell.parentNode.rowIndex
	       || logicalTable[top][left][1] != cell.cellIndex))
	left++;
    var bottom = (isNaN(cell.rowSpan)) ? top : top + cell.rowSpan - 1;
    var right = (isNaN(cell.colSpan)) ? left : left + cell.colSpan - 1;
    return { top: top,
	     left: left,
	     bottom: bottom,
	     right: right };
}

/*
 * union
 */
function combineBoxes(cell1, cell2) {
    return { top: (cell1.top < cell2.top) ? cell1.top : cell2.top,
             left: (cell1.left < cell2.left) ? cell1.left : cell2.left,
             bottom: (cell1.bottom > cell2.bottom) ? cell1.bottom : cell2.bottom,
             right: (cell1.right > cell2.right) ? cell1.right : cell2.right };
}

/*
 * intersection test
 */
function boxIntersects(box1, box2) {
    return box1.left <= box2.right
	&& box1.right >= box2.left 
	&& box1.top <= box2.bottom
	&& box1.bottom >= box2.top;
}

/*
 * counts table rows and columns, taking into account colspans and rowspans.
 * assumes all rows have the same number of columns.
 *
 * builds logicalTable, a 2d array where each value is an array containing the row
 * and col of the cell in the html table to which it maps.
 */
function computeLogicalTable() {
    // figure out the size of the logical table
    cols = 0;
    rows = $("tr", tbl).length;
    $("tr:first > th, tr:first > td", tbl).each(function() {
	if (isNaN($(this).attr("colSpan")))
	    cols++;
	else
	    cols += parseInt($(this).attr("colSpan"));
    });

    // allocate the logical table
    logicalTable = new Array();
    for (var rr = 0; rr < rows; rr++) {
	logicalTable[rr] = new Array();
	for (var cc = 0; cc < cols; cc++) {
	    logicalTable[rr][cc] = new Array();
	    logicalTable[rr][cc][0] = -1;
	    logicalTable[rr][cc][1] = -1;
	}
    }

    // go through the actual table cells, row by row, filling in the logical table with
    // indices to which actual cell each logical cell points.
    $("th, td", tbl).each(function() {
	var aRow = this.parentNode.rowIndex; // actual row (in html)
	var aCol = this.cellIndex;	     // actual col
	var lRow = aRow; // logical row (in table)
	var lCol = aCol;  // logical col
	while (logicalTable[lRow][lCol][0] != -1)
	    lCol++;
	var rowSpan = (this.rowSpan > 1) ? this.rowSpan : 1;
	var colSpan = (this.colSpan > 1) ? this.colSpan : 1;
	for (var rr = lRow; rr < (lRow + rowSpan); rr++) {
	    for (var cc = lCol; cc < (lCol + colSpan); cc++) {
		logicalTable[rr][cc][0] = aRow;
                logicalTable[rr][cc][1] = aCol;
	    }
	}
    });
}

/*
 * compute the xpath for the given node
 */
function getXPath(node) {
    if (node.id == "remote_page") {
	return "";
    } else {
	var indexVal = 1;
	var indexStr = "";
	for (var ii = 0; ii < node.parentNode.childNodes.length; ii++) {
	    if (node.parentNode.childNodes[ii] == node && indexVal > 0) {
		indexStr = "[" + indexVal + "]";
		break;
	    }
	    if (node.parentNode.childNodes[ii].nodeName == node.nodeName)
		indexVal++;
	}
	var sepStr = "/";
	var parentStr = getXPath(node.parentNode);
	if (parentStr == "")
	    sepStr = "";
	return parentStr + sepStr + node.nodeName + indexStr;
    }
}
