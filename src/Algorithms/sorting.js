/*
 * Sorting Algorithm Examples in Javascript.
 *
 * Written by Bryce Summers on 6/10/2015.
 *
 * Please See the Following slides for descriptions of these sorting algorithms.
 * https://docs.google.com/presentation/d/1V5Z6Olkhy7M44InR2ficm6iCLOC5-QstHq-8OD5mcjs/edit?usp=sharing
 *
 * This code has been annotated to store information for a pedagogical sorting algorithm visualization.
 */

// Constructor.
function Sort(){

	this.small_cutoff = 10;
	this.swaps = [];

}

Sort.prototype = {
  
  selection_sort: function(array)
  {
	this.FUNCTION_CALL("Selection Sort");
	var len = array.length;
	
	for(var i = 0; i < len; i++)
	{
		this.HEAD1(i);
		var min_index = this.min(array, i, len);
		this.swap(array, i, min_index);
	}
	
	this.FUNCTION_RETURN();
  },

  insertion_sort: function(array)
  {
	this.FUNCTION_CALL("Insertion Sort Wrapper Function");
	this.insertion_sort_h(array, 0, array.length);
	this.FUNCTION_RETURN();
  },
  
  insertion_sort_h: function(array, start, end)
  {
	this.FUNCTION_CALL("Insertion Sort");
	this.REGION(start, end);
	for(var i = start + 1; i < end; i++)
	{
		this.HEAD3(i);
		var val = array[i];
		var insert_index = i;
		
		while(insert_index > start && array[insert_index - 1] > val)
		{
			this.HEAD1(insert_index);
			this.HEAD2(insert_index - 1);
			this.swap(array, insert_index, insert_index - 1);
			insert_index--;
		}
	}
	this.FUNCTION_RETURN();
  },  
  
  quick_sort: function(array)
  {
	this.FUNCTION_CALL("Quick Sort Wrapper.");
	this.quick_sort_h(array, 0, array.length);
	this.FUNCTION_RETURN();
  },

  // Start is inclusive, end is exclusive.
  quick_sort_h: function(array, start, end)
  {
	this.FUNCTION_CALL("Quick Sort");
	this.REGION(start, end);
  
	// Insertion sort is more efficient for small regions.
	if(end - start < this.small_cutoff)
	{
		this.insertion_sort_h(array, start, end);
		this.FUNCTION_RETURN();
		return;
	}

    var randomIndex1 = this.randInt(start, end);
	var randomIndex2 = this.randInt(start, end);
	var randomIndex3 = this.randInt(start, end);
	
	var pivot_index = this.med3(array, randomIndex1, randomIndex2, randomIndex3);

	// Partition all of the elements into those smaller and larger than the pivot.
	pivot_index = this.partition(array, start, end, pivot_index);
	
	// Recursion.
	this.quick_sort_h(array, start, pivot_index);
	this.quick_sort_h(array, pivot_index, end);

	this.FUNCTION_RETURN();
  },

  partition: function(array, start, end, pivot_index)
  {
  	this.FUNCTION_CALL("Partition");
	  
	var pivot_val = array[pivot_index];
  
	this.HEAD1(pivot_index);
	this.HEAD2(end-1);
  
	// Swap the pivot to safety.
	this.swap(array, pivot_index, end - 1);
	pivot_index = end - 1;
	
	this.HEAD3(pivot_index);
			
	var len = end - start;
	var left_index = start;
	var right_index = end - 1;
	
	this.HEAD1(left_index);
	this.HEAD2(right_index);
	
	for(var i = 0; i < len - 1; i++)
	{
		if(array[left_index] <= pivot_val)
		{
			left_index++;
			this.HEAD1(left_index);
			continue;
		}
		
		right_index--;
		this.HEAD2(right_index);
		this.swap(array, left_index, right_index);
	}
	
	this.HEAD1(pivot_index);
	// Swap the pivot to the left of the section of elements greater than the pivot.
	this.swap(array, right_index, pivot_index);
	pivot_index = right_index;
	
	this.FUNCTION_RETURN();
	
	return pivot_index;
  },
  
  merge_sort: function(array)
  {
	this.FUNCTION_CALL("Merge Sort Wrapper Function.");
	this.merge_sort_h(array, 0, array.length);
	this.FUNCTION_RETURN();
  },
  
  // Recursive Based Merge Sort.
  merge_sort_h: function(array, start, end)
  {
	this.FUNCTION_CALL("Merge Sort.");
	this.REGION(start, end);
	
	if(end - start < this.small_cutoff)
	{
		this.insertion_sort_h(array, start, end);
		this.FUNCTION_RETURN();
		return;
	}
	
	var middle = Math.floor((start + end) / 2); //start/2 + end/2 is better against integer overflow.
	
	this.merge_sort_h(array, start, middle);
	this.merge_sort_h(array, middle, end);
		
	this.merge(array, start, middle, end);
	
	this.FUNCTION_RETURN();
  },
  
  merge: function(array, start, middle, end)
  {
	this.FUNCTION_CALL("Merge two sorted lists into one.");
	this.REGION(start, end);
  
	console.log("Merge Input = " + array);

	var output = [];
	
	var len = end - start;
	
	var left_index  = start;
	var right_index = middle;
	
	this.HEAD1(left_index);
	this.HEAD2(right_index);
	
	// Proceed until either section is empty.
	while(left_index < middle && right_index < end)
	{
		if(array[left_index] <= array[right_index])
		{
			output.push(array[left_index]);
			left_index++;
			this.HEAD1(left_index);
		}
		else
		{
			output.push(array[right_index]);
			right_index++;
			this.HEAD2(right_index);
		}
	}
	
	this.HEAD2(-1);
	
	// Enqueue the remaining elements in left and right.
	for(var i = left_index; i < middle; i++)
	{
		this.HEAD1(i);
		output.push(array[i]);
	}
	for(var i = right_index; i < end; i++)
	{		
		this.HEAD1(i);
		output.push(array[i]);
	}
	
	// Copy the output array back to the original array.
	for(var i = start; i < end; i++)
	{
		this.HEAD1(i);
		array[i] = output[i - start];
		this.SET(i, output[i - start]);
	}
	
	this.FUNCTION_RETURN();
  }, 
  	
  // -- Helper Functions.
  
  swap: function(array, index1, index2)
  {
	var temp = array[index1];
	array[index1] = array[index2];
	array[index2] = temp;
  
	// Record which swaps took place.
	this.swaps.push("SWAP");
	this.swaps.push(index1);
	this.swaps.push(index2);
  },
  
  // Returns the index of the leftmost minimum element.
  min: function(array, index_first_inclusive, index_last_exclusive)
  {
	this.FUNCTION_CALL("Find minimum element.");
  
	var output_val = array[index_first_inclusive];
	var output = index_first_inclusive;
  
	for(var i = index_first_inclusive + 1; i < index_last_exclusive; i++)
	{
		this.HEAD3(i);
		var check_val = array[i];
		if(check_val < output_val)
		{
			output = i;
			output_val = check_val;
			this.HEAD2(i);
		}
	}
	
	this.FUNCTION_RETURN();
	return output;
  },
  
  // Returns the index of the median of the elements at the three indices.
  med3: function(array, index1, index2, index3)
  {
	var max;
	var not_max_1;
	var not_max_2;
	
	// Find the maximum element and the two non maximum elements.
	if(array[index1] > array[index2])
	{
		max = index1;
		not_max_1 = index2;
	}
	else
	{
		max = index2;
		not_max_1 = index1;
	}
	
	if(array[max] > array[index3])
	{
		not_max_2 = index3;
	}
	else
	{
		not_max_2 = max;
		max = index3;
	}
	
	// Return the maximum of the two non maximal elements.
	if(array[not_max_1] < array[not_max_2])
	{
		return not_max_2;
	}
	else
	{
		return not_max_1;
	}
  },
  
   // Returns a random integer between min is inclusive, max is exclusive.
  randInt: function(min, max)
  {
	var diff = max - min;
	var output = Math.floor((Math.random() * diff) + min);
	return output;
  },
  
  HEAD1: function(val)
  {
  	this.swaps.push("HEAD1");
	this.swaps.push(val);
	this.swaps.push(0);// bogus.
  },
  
  HEAD2: function(val)
  {
  	this.swaps.push("HEAD2");
	this.swaps.push(val);
	this.swaps.push(0);// bogus.
  },
  HEAD3: function(val)
  {
  	this.swaps.push("HEAD3");
	this.swaps.push(val);
	this.swaps.push(0);// bogus.
  },
  
  SET: function(index, val)
  {
  	this.swaps.push("SET");
	this.swaps.push(index);
	this.swaps.push(val);
  },
  
  REGION: function(start, end)
  {
	this.swaps.push("REGION");
	this.swaps.push(start);
	this.swaps.push(end);
  },
  
  FUNCTION_CALL: function(name)
  {
	this.swaps.push("FUNCTION_CALL");
	this.swaps.push(name);
	this.swaps.push(0);// bogus. This could be used to store tagging information for what the heads mean.
  },
  
  FUNCTION_RETURN: function(name)
  {
	this.swaps.push("FUNCTION_RETURN");
	this.swaps.push(0);// bogus.
	this.swaps.push(0);// bogus.
  }
};