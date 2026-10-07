// Layout chính cho các trang public của BookStore
import { Navbar } from '@/components/navbar';
import { Footer } from '@/components/footer';
import { FallingLeaves } from '@/components/falling-leaves';
import { Chatbot } from '@/components/chatbot';


export default function MainLayout({
                                       children,
                                   }: {
    children: React.ReactNode;
}) {
    return (
        <div className="min-h-screen flex flex-col bg-background">
            {/* Hiệu ứng lá rơi */}
            <FallingLeaves />

            {/* Navbar */}
            <Navbar />

            {/* Main Content */}
            <main className="flex-1 relative z-10">
                {children}
            </main>

            {/* Footer */}
            <Footer />

            {/* Chatbot */}
            <Chatbot />

        </div>
    );
}