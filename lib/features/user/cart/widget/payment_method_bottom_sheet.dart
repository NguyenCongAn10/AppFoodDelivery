import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:flutter/material.dart';

enum PaymentMethod {
  cash,
  visa,
  paypal,
}

class PaymentMethodBottomSheet extends StatefulWidget {
  final Function(PaymentMethod) onSelected;

  const PaymentMethodBottomSheet({
    super.key,
    required this.onSelected,
  });

  @override
  State<PaymentMethodBottomSheet> createState() => _PaymentMethodBottomSheetState();
}

class _PaymentMethodBottomSheetState extends State<PaymentMethodBottomSheet> {
  PaymentMethod _selectedMethod = PaymentMethod.cash;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: BoxDecoration(
        color: AppColor.container(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          const SizedBox(height: 25),
          Text(
            "Select Payment Method",
            style: AppTextStyle.bodyBold(context, fontSize: 20),
          ),
          const SizedBox(height: 20),
          _buildPaymentOption(
            method: PaymentMethod.cash,
            title: "Cash on Delivery",
            icon: Icons.money,
            subTitle: "Pay when you receive your food",
          ),
          const SizedBox(height: 12),
          _buildPaymentOption(
            method: PaymentMethod.visa,
            title: "Visa / Mastercard",
            icon: Icons.credit_card,
            subTitle: "**** **** **** 4521",
          ),
          const SizedBox(height: 12),
          _buildPaymentOption(
            method: PaymentMethod.paypal,
            title: "PayPal",
            icon: Icons.account_balance_wallet,
            subTitle: "john.doe@example.com",
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                widget.onSelected(_selectedMethod);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
              child: Text(
                "Confirm Payment",
                style: AppTextStyle.bodyBold(context, color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required PaymentMethod method,
    required String title,
    required String subTitle,
    required IconData icon,
  }) {
    final isSelected = _selectedMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.primary(context).withOpacity(0.05)
              : AppColor.inputFill(context).withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColor.primary(context) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppColor.primary(context) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColor.textSecondary(context),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyle.bodyBold(context,
                        fontSize: 16,
                        color: isSelected ? AppColor.primary(context) : AppColor.textTitle(context)),
                  ),
                  Text(
                    subTitle,
                    style: AppTextStyle.body(context,
                        fontSize: 13, color: AppColor.textSecondary(context)),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColor.primary(context))
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.withOpacity(0.3), width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
