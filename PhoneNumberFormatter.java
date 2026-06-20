package cn.choicelink.abpzjk.util;

public class PhoneNumberFormatter {

    // 默认的中国手机号格式（3-4-4）
    private static final int[] DEFAULT_PATTERN = {3, 4, 4};

    /**
     * 使用默认格式（3-4-4）和默认分隔符（-）格式化手机号
     */
    public static String format(String phoneNumber) {
        return format(phoneNumber, DEFAULT_PATTERN, "-");
    }

    /**
     * 自定义格式化模式和分隔符
     *
     * @param phoneNumber 手机号字符串（应为纯数字）
     * @param pattern     分段长度数组，如 {3, 4, 4}
     * @param separator   分隔符，如 "-" 或 " "
     * @return 格式化后的字符串
     */
    public static String format(String phoneNumber, int[] pattern, String separator) {
        if (phoneNumber == null || phoneNumber.isEmpty()) {
            throw new IllegalArgumentException("手机号不能为空");
        }
        if (!phoneNumber.matches("\\d+")) {
            throw new IllegalArgumentException("手机号必须为纯数字");
        }

        StringBuilder formatted = new StringBuilder();
        int currentIndex = 0;

        for (int partLength : pattern) {
            if (currentIndex + partLength > phoneNumber.length()) {
                throw new IllegalArgumentException("手机号长度不足以匹配指定格式");
            }
            formatted.append(phoneNumber, currentIndex, currentIndex + partLength);
            currentIndex += partLength;
            if (currentIndex < phoneNumber.length()) {
                formatted.append(separator);
            }
        }

        // 添加剩余部分（如果有的话）
        if (currentIndex < phoneNumber.length()) {
            formatted.append(separator).append(phoneNumber.substring(currentIndex));
        }

        return formatted.toString();
    }

    /**
     * 去除所有格式，返回原始手机号
     */
    public static String unformat(String formattedPhoneNumber) {
        if (formattedPhoneNumber == null) return "";
        return formattedPhoneNumber.replaceAll("[^\\d]", "");
    }

    // 测试用例
    public static void main(String[] args) {
        String phone = "13800138000";

        // 默认格式
        System.out.println("默认格式: " + format(phone)); // 输出: 138-0013-8000

        // 自定义格式和分隔符
        System.out.println("自定义格式: " + format(phone, new int[]{3, 3, 4}, " ")); // 输出: 138 001 38000

        // 反格式化
        System.out.println("反格式化: " + unformat("138-0013-8000")); // 输出: 13800138000
    }
}