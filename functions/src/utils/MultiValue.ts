export default class MultiValue<T extends number|string> {
    values: Array<T>;
    constructor(array?: Array<T>) {
        this.values = array ? array : [];
        this.values.sort();
    }

    /**
     * Add a value
     */
    add(value: T): MultiValue<T> {
        this.binaryInsert(value);
        return this;
    }

    private binaryInsert(value: T, start: number = 0, end: number = this.values.length - 1) :void {
        const middle = Math.floor((start + end) / 2);
        if (this.length === 0) {
            this.values.push(value);
        } else if (value > this.values[end]) {
            this.values.splice(end + 1, 0, value);
        } else if (value < this.values[start]) {
            this.values.splice(start, 0, value);
        } else if (start >= end) {
            // Don't insert duplicate
            return;
        } else if (value < this.values[middle]) {
            this.binaryInsert(value, start, middle - 1);
        } else if (value < this.values[middle]) {
            this.binaryInsert(value, middle + 1, end);
        }
        // Don't insert duplicate
    }

    /**
     * Add an array of values
     * @param values 
     */
    addValues(values: Array<T>) : MultiValue<T> {
        values.forEach(this.add);
        return this;
    }

    /**
     * Add another MultiValue
     * @param other 
     */
    addMulti(other: MultiValue<T>): MultiValue<T>  {
        other.forEach(this.add)
        return this;
    }

    forEach(func: (value :T, index: number, self: Array<T>) => void): void {
        this.values.forEach(func);
    }

    get length() : number {
        return this.values.length
    }

    remove(value: T): MultiValue<T> {
        this.values = this.values.filter(function (thisValue) {
            return thisValue !== value;
        });
        return this;
    }

    contains(value: T): boolean {
        return this.values.some(function(thisValue) {
            return thisValue === value;
        });
    }

    copy(): MultiValue<T> {
        const result = new MultiValue<T>();
        return result.addMulti(this);
    }

    diff(other: MultiValue<T>): MultiValue<T> {
        if (this.length === 0 || other.length ===0) {
            return this.copy();
        }
        const result = new MultiValue<T>();
        let thisIndex = 0;
        let otherIndex = 0;
        while (thisIndex < this.length) {
            const thisValue = this.values[thisIndex];
            const otherValue = otherIndex < other.length ? other.values[otherIndex] : null;
            if (thisValue === otherValue) {
                thisIndex++;
                otherIndex++;
            } else if (otherValue === null || thisValue < otherValue) {
                result.add(thisValue);
                thisIndex++;
            } else {
                otherIndex++;
            }
        }
        return result;
    }

    equals(other: MultiValue<T>) : boolean {
        if (this.length !== other.length) {
            return false;
        };
        if (this.length === 0) {
            return true;
        }
        let isEqual = true;
        for (let index = 0; index < this.length; index++) {
            if (this.values[index] !== other.values[index]) {
                isEqual = false;
                break;
            }
        }
        return isEqual;
    }
}