type TDFlutterNestedValue = string | number | boolean | null | TDFlutterNestedMap | TDFlutterNestedValue[];
type TDFlutterNestedMap = Map<string, TDFlutterNestedValue>;
type TDFlutterNestedObject = Record<string, any>;
export class TDFlutterUtils extends Object {
  static mapToJsonObject<K extends string, V>(map: Map<K, V>): Record<K, V> {
    const obj: Record<K, V> = {} as Record<K, V>;
    map.forEach((value, key) => {
      obj[key] = value; //逐项赋值
    });
    return obj;
  }

  static convertMapToJsonObject(obj: object): TDFlutterNestedObject {
    const result: TDFlutterNestedObject = {};
    let map = obj as TDFlutterNestedMap
    map.forEach((value, key) => {
      if (value instanceof Map) {
        // 递归处理嵌套Map
        result[key] = this.convertMapToJsonObject(value);
      } else if (Array.isArray(value)) {
        // 处理数组中的Map元素
        result[key] = value.map(item =>
        item instanceof Map ? this.convertMapToJsonObject(item) : item
        );
      } else {
        result[key] = value;
      }
    });
    return result;
  }
}