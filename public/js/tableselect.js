// globals
var one, two, rows, cols, tbl, logicalTable;

$(document).ready(function()
{
    $("#remote_page table").addClass("data");
    $("#remote_page table").mousedown(click);
});

function clear(event)
{
    one = undefined;
    two = undefined;

    $("th,td").removeClass("selected");
}

function click(event)
{
    if (!event.target)
	return;

    if (!event.shiftKey)
    {
	tbl = event.target.parentNode.parentNode.parentNode;
	computeLogicalTable()

	clear(event);

	one = event.target;
	$(one).addClass("selected");

	//$("input[@name=status]").attr("value", getXPath(one));
    }
    else
    {
	if (one == null)
	    return;

	two = event.target;
	$(two).addClass("selected");

	update();
    }
    return false;
}

function update()
{
    var r1, r2, c1, c2; // logical row and col

    boxOne = lookupLogicalCorners(one);
    boxTwo = lookupLogicalCorners(two);
    selectedBox = combineBoxes(boxOne, boxTwo);

    //alert(selectedBox.top + " " + selectedBox.left + " " + selectedBox.bottom + " "+ selectedBox.right);
    $("th,td", tbl).each(function()
    {
	if (boxIntersects(lookupLogicalCorners(this), selectedBox))
	    $(this).addClass("selected");
	else
	    $(this).removeClass("selected");
    });
}

function lookupLogicalCorners(cell)
{
    top = cell.parentNode.rowIndex;
    left = cell.cellIndex;
    while (logicalTable[top].length>left
	   && (logicalTable[top][left][0]!=cell.parentNode.rowIndex
	       || logicalTable[top][left][1]!=cell.cellIndex))
	left++;
    bottom = (isNaN(cell.rowSpan)) ? top : top+cell.rowSpan-1;
    right = (isNaN(cell.colSpan)) ? left : left+cell.colSpan-1;
    return {
	top: top,
	    left: left,
	    bottom: bottom,
	    right: right
	    };
}

function combineBoxes(cell1, cell2)
{
    return {
	top: (cell1.top<cell2.top) ? cell1.top : cell2.top,
	    left: (cell1.left<cell2.left) ? cell1.left : cell2.left,
	    bottom: (cell1.bottom>cell2.bottom) ? cell1.bottom : cell2.bottom,
	    right: (cell1.right>cell2.right) ? cell1.right : cell2.right
	    };
}

function boxIntersects(box1, box2)
{
    return box1.left <= box2.right
	&& box1.right >= box2.left 
	&& box1.top <= box2.bottom
	&& box1.bottom >= box2.top;
}

function setCols()
{
    $("input[@name=colsField]").attr("value", $.map($("th.selected,td.selected"), function(nn,ii){ return nn.innerHTML; }));
}

function setRows()
{
    $("input[@name=rowsField]").attr("value", $.map($("th.selected,td.selected"), function(nn,ii){ return nn.innerHTML; }));
}

function setData()
{
    $("input[@name=dataField]").attr("value", $.map($("th.selected,td.selected"), function(nn,ii){ return nn.innerHTML; }));
}

// counts table rows and column, taking into account col and rowspans
// assumes all rows have the same number of columns
function computeLogicalTable()
{
    // figure out the size of the logical table
    cols = 0;
    rows = $("tr", tbl).length;
    $("tr:first > th,tr:first > td").each(function()
    {
	if (isNaN($(this).attr("colSpan")))
	    cols++;
	else
	    cols += parseInt($(this).attr("colSpan"));
    });

    // allocate the logical table
    logicalTable = new Array();
    for (rr=0; rr<rows; rr++)
    {
	logicalTable[rr] = new Array();
	for (cc=0; cc<cols; cc++)
	{
	    logicalTable[rr][cc] = new Array();
	    logicalTable[rr][cc][0] = -1;
	    logicalTable[rr][cc][1] = -1;
	}
    }

    // go through the actual table cells, row by row, filling in the logical table with
    // indices to which actual cell each logical cell points.
    $("th,td", tbl).each(function()
    {
	var aRow = this.parentNode.rowIndex; // actual row (in html)
	var aCol = this.cellIndex;	     // actual col
	var lRow = aRow; // logical row (in table)
	var lCol = aCol;  // logical col
	while (logicalTable[lRow][lCol][0]!=-1)
	    lCol++;
	var rowSpan = (this.rowSpan>1) ? this.rowSpan : 1;
	var colSpan = (this.colSpan>1) ? this.colSpan : 1;
	for (rr=lRow; rr<lRow+rowSpan; rr++)
	{
	    for (cc=lCol; cc<lCol+colSpan; cc++)
	    {
		logicalTable[rr][cc][0] = aRow;
		logicalTable[rr][cc][1] = aCol;
	    }
	}
    });
}

// compute the xpath for the given node
function getXPath(node)
{
    if (node.parentNode == null)
	return "";
    else
    {
	var index = "";
	for (var ii=0; ii<node.parentNode.childNodes.length; ii++)
	  if (node.parentNode.childNodes[ii] == node)
	      if (ii>0)
		  index = "[" + ii + "]";
	return getXPath(node.parentNode)  + "/" + node.nodeName + index;
    }
}