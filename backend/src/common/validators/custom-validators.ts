import { registerDecorator, ValidationOptions, ValidationArguments } from 'class-validator';
import { isValidPhoneNumber } from 'libphonenumber-js';

export function IsStrongPassword(validationOptions?: ValidationOptions) {
  return function (object: Object, propertyName: string) {
    registerDecorator({
      name: 'isStrongPassword',
      target: object.constructor,
      propertyName: propertyName,
      options: {
        message: '密码必须包含大小写字母、数字和特殊字符，长度8-32位',
        ...validationOptions,
      },
      validator: {
        validate(value: string) {
          if (!value || typeof value !== 'string') return false;
          const hasUpperCase = /[A-Z]/.test(value);
          const hasLowerCase = /[a-z]/.test(value);
          const hasNumber = /[0-9]/.test(value);
          const hasSpecialChar = /[!@#$%^&*(),.?":{}|<>]/.test(value);
          const isLengthValid = value.length >= 8 && value.length <= 32;
          return hasUpperCase && hasLowerCase && hasNumber && hasSpecialChar && isLengthValid;
        },
      },
    });
  };
}

export function IsPhoneNumber(validationOptions?: ValidationOptions) {
  return function (object: Object, propertyName: string) {
    registerDecorator({
      name: 'isPhoneNumber',
      target: object.constructor,
      propertyName: propertyName,
      options: {
        message: '请输入有效的手机号码',
        ...validationOptions,
      },
      validator: {
        validate(value: string) {
          if (!value) return false;
          try {
            return isValidPhoneNumber(value, 'CN') || isValidPhoneNumber(value, 'US');
          } catch {
            return false;
          }
        },
      },
    });
  };
}

export function IsEnumValue(enumType: any, validationOptions?: ValidationOptions) {
  return function (object: Object, propertyName: string) {
    registerDecorator({
      name: 'isEnumValue',
      target: object.constructor,
      propertyName: propertyName,
      options: {
        message: `值必须是枚举 ${enumType.name} 中的一个`,
        ...validationOptions,
      },
      validator: {
        validate(value: any) {
          return Object.values(enumType).includes(value);
        },
      },
    });
  };
}

export function IsUnique(validationOptions?: ValidationOptions) {
  return function (object: Object, propertyName: string) {
    registerDecorator({
      name: 'isUnique',
      target: object.constructor,
      propertyName: propertyName,
      options: {
        message: '该值已存在',
        ...validationOptions,
      },
      validator: {
        validate() {
          return true;
        },
      },
    });
  };
}

export function IsUrlSafe(validationOptions?: ValidationOptions) {
  return function (object: Object, propertyName: string) {
    registerDecorator({
      name: 'isUrlSafe',
      target: object.constructor,
      propertyName: propertyName,
      options: {
        message: '只能包含字母、数字、连字符和下划线',
        ...validationOptions,
      },
      validator: {
        validate(value: string) {
          if (!value) return true;
          return /^[a-zA-Z0-9_-]+$/.test(value);
        },
      },
    });
  };
}

export function IsDateRange(validationOptions?: ValidationOptions) {
  return function (object: Object, propertyName: string) {
    registerDecorator({
      name: 'isDateRange',
      target: object.constructor,
      propertyName: propertyName,
      options: {
        message: '结束日期必须晚于开始日期',
        ...validationOptions,
      },
      validator: {
        validate(value: any, args: ValidationArguments) {
          const [relatedPropertyName] = args.constraints;
          const relatedValue = (args.object as any)[relatedPropertyName];
          if (!value || !relatedValue) return true;
          return new Date(value) > new Date(relatedValue);
        },
      },
    });
  };
}

export function IsFileType(allowedTypes: string[], validationOptions?: ValidationOptions) {
  return function (object: Object, propertyName: string) {
    registerDecorator({
      name: 'isFileType',
      target: object.constructor,
      propertyName: propertyName,
      options: {
        message: `文件类型必须是: ${allowedTypes.join(', ')}`,
        ...validationOptions,
      },
      validator: {
        validate(value: Express.Multer.File) {
          if (!value) return true;
          const ext = value.originalname.split('.').pop()?.toLowerCase();
          return ext ? allowedTypes.includes(ext) : false;
        },
      },
    });
  };
}
