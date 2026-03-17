import nodemailer from 'nodemailer';

const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
    },
});

export const sendOtpEmail = async (email, otp) => {
    console.log(`[OTP LOG] Sending OTP ${otp} to ${email}`);
    
    if (!process.env.EMAIL_USER || !process.env.EMAIL_PASS) {
        console.log("Email credentials not found. Skipping real email send.");
        return;
    }

    const mailOptions = {
        from: process.env.EMAIL_USER,
        to: email,
        subject: 'Mã xác thực đăng ký App Food Delivery',
        text: `Mã OTP của bạn là: ${otp}. Mã này có hiệu lực trong 5 phút.`,
        html: `<h3>Mã xác thực đăng ký</h3>
               <p>Mã OTP của bạn là: <b>${otp}</b></p>
               <p>Mã này có hiệu lực trong 5 phút.</p>`,
    };

    try {
        await transporter.sendMail(mailOptions);
        console.log(`Email sent successfully to ${email}`);
    } catch (error) {
        console.error("Error sending email:", error);
    }
};
