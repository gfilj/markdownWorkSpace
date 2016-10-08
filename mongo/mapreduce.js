db.load_action_response_time.mapReduce(
	function () {
	var value = {
		count : 1,
		responseTime : this.responseTime
	};
	emit(this.jobName, value);
},
	function (keySKU, countObjVals) {
	var sum = Array.sum(countObjVals.responseTime);
	var sampleCount = Array.sum(countObjVals.count);
	countObjVals.sort(function (a, b) {
		return a.responseTime - b.responseTime
	});
	var reducedVal = {
		count : sum,
		id : keySKU,
		sample : sampleCount
	};
	return reducedVal;
}, {
	out : {
		inline : 1
	},
	query : {
		jobName : "test08262016-08-2917:32:10.923"
	},
})

minTime : countObjVals[0],
maxTime : countObjVals[countObjVals.length - 1].responseTime,
line90 : countObjVals[parseInt(countObjVals.length * 0.9)].responseTime,
median : countObjVals[parseInt(countObjVals.length * 0.5)].responseTime,

var mapFunction2 = function () {
	emit(1, this);
};

var reduceFunction2 = function (keySKU, countObjVals) {
	sum = 0;
	for (var i = 0; i < countObjVals.length; i++) {
		sum += countObjVals[i].responseTime;
	};
	countObjVals.sort(function (a, b) {
		return a.responseTime - b.responseTime
	});
	reducedVal = {
		count : sum,
		id : keySKU,
		minTime : countObjVals[0],
		maxTime : countObjVals[countObjVals.length - 1],
		line90 : countObjVals[parseInt(countObjVals.length * 0.9)],
		median : countObjVals[parseInt(countObjVals.length * 0.5)],
		sample : countObjVals.length
	};
	return reducedVal;
};

reducedVal.count = sum;
reducedVal.id = keySKU;
reducedVal.minTime = countObjVals[0].responseTime;
reducedVal.maxTime = countObjVals[countObjVals.length - 1].responseTime;
reducedVal.line90 = countObjVals[parseInt(countObjVals.length * 0.9)].responseTime;
reducedVal.median = countObjVals[parseInt(countObjVals.length * 0.5)].responseTime;
reducedVal.sample = countObjVals.length;

var emit = function (key, value) {
	print("emit");
	print("key: " + key + "  value: " + tojson(value));
}
var reducedValue = {
	count : 0,
	id : "",
	minTime : 0,
	maxTime : 0,
	line90 : 0,
	median : 0,
	sample : 0,
	array : []
};

db.load_action_response_time.mapReduce(
	function () {
	var key = this.jobName;
	var value = {
		count : 1,
		responseTime : this.responseTime,
		responseSize : this.responseSize,
		array : [this.responseTime]
	};
	value.array[0] = this.responseTime;
	emit(key, value);
},
	function (keySKU, countObjVals) {
	var reducedVal = {
		count : 0,
		responseTime : 0,
		responseSize : 0,
		array : new Array()
	};
	id = keySKU;
	countObjVals.forEach(function (valueObj) {
		reducedVal.count += valueObj.count;
		reducedVal.responseTime += valueObj.responseTime;
		reducedVal.responseSize += valueObj.responseSize;
		reducedVal.array = reducedVal.array.concat(valueObj.array);
	});
	return reducedVal;
}, {
	out : {
		inline : 1
	},
	query : {
		jobName : "投票系统压力测试2016-09-0115:25:00.520"
	},
	finalize : function (key, reducedVal) {

		reducedVal.average = reducedVal.responseTime / reducedVal.count;
		reducedVal.KBsec = reducedVal.responseSize * 1000 / reducedVal.responseTime;
		reducedVal.array.sort(function (a, b) {
			return a - b;
		});
		reducedVal.min = reducedVal.array[0];
		reducedVal.max = reducedVal.array[reducedVal.count - 1];
		reducedVal.median = reducedVal.array[parseInt(reducedVal.count * 0.5)];
		reducedVal.line90 = reducedVal.array[parseInt(reducedVal.count * 0.9)];
		reducedVal.array = [];
		return reducedVal;
	}
});


reducedVal.sample += reducedVal.sample;
reducedVal.array.push(reducedVal.array);
reducedVal.array.sort(function (a, b) {
	return a.minTime - b.minTime
});

reducedVal.minTime = reducedVal.array[0];
reducedVal.maxTime = reducedVal.array[reducedVal.sample - 1];
reducedVal.line90 = reducedVal.array[parseInt(reducedVal.sample * 0.9)];
reducedVal.median = reducedVal.array[parseInt(reducedVal.sample * 0.5)];
db.runCommand({
	'mapReduce' : 'load_action_response_time',
	'map' : function () {
		var key = this.jobName;
		var value = {
			count : 1,
			id : "",
			minTime : 0,
			maxTime : 0,
			line90 : 0,
			median : 0,
			sample : 0
		};
		value.minTime = this.responseTime;
		emit(key, value);
	},
	'reduce' : function (keySKU, countObjVals) {
		reducedValue = {
			count : 0,
			id : "",
			minTime : 0,
			maxTime : 0,
			line90 : 0,
			median : 0,
			sample : 0
		};
		countObjVals.forEach(function (value) {
			reducedValue.sample += value.count;
		});
		return reducedValue;
	},
	'out' : {
		inline : 1
	},
	'query' : {
		jobName : "test08262016-08-2917:32:10.923",
		actionId : NumberLong(11149)
	}

});

var map = function () {
	var key = this.jobName;
	var value = {
		count : 0,
		id : "",
		minTime : 0,
		maxTime : 0,
		line90 : 0,
		median : 0,
		sample : 0
	};
	value.minTime = this.responseTime;
	emit(key, value);
};
var emit = function (key, value) {
	print("emit");
	print("key: " + key + "  value: " + tojson(value));
}

var myDoc = db.load_action_response_time.find({
		jobName : "test08262016-08-2917:32:10.923"
	});

var count = 0;
while (myDoc.hasNext()) {
	var doc = myDoc.next();
	print("document _id= " + tojson(doc._id));
	map.apply(doc);
	print();
	count++;
}
print("count is: " + count);